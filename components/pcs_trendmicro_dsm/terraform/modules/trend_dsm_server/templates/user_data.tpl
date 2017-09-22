#!/bin/bash -xe
#cloud-init
# A quick fix because permissions on the ec2-user home directory are wrong
sudo chown ec2-user:ec2-user /home/ec2-user -R

mkdir /etc/cfn

# sleep for 30 seconds and give the instance metadata time to catch up.
sleep 30 

set the proxy server settings
export proxy="${squid_elb_address}:${squid_elb_port}"
if [ $proxy != "no-proxy" ]; then
	sudo echo "export no_proxy='169.254.169.254,localhost,127.0.0.1,localaddress,.localdomain.com,${dsm_elb_url}'" > /etc/profile.d/proxy.sh
    sudo echo "export HTTP_PROXY=http://$proxy/" >> /etc/profile.d/proxy.sh
    sudo echo "export http_proxy=http://$proxy/" >> /etc/profile.d/proxy.sh
    sudo echo "export HTTPS_PROXY=http://$proxy/" >> /etc/profile.d/proxy.sh
    sudo echo "export https_proxy=http://$proxy/" >> /etc/profile.d/proxy.sh
    sudo chmod a+x /etc/profile.d/proxy.sh
    source /etc/profile.d/proxy.sh
fi

export ip_address="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"
export local_hostname="$(curl http://169.254.169.254/latest/meta-data/local-hostname/)"

#create the dsm configuration parameters file
echo "CredentialsScreen.Administrator.Username=${dsm_username}" > /tmp/dsmConfiguration.properties
echo "CredentialsScreen.Administrator.Password=${dsm_password}" >> /tmp/dsmConfiguration.properties
echo "CredentialsScreen.UseStrongPasswords=False" >> /tmp/dsmConfiguration.properties
echo "Dinstall4j.language=en" >> /tmp/dsmConfiguration.properties
echo "DatabaseScreen.DatabaseType=${dsm_db_type}" >> /tmp/dsmConfiguration.properties
echo "DatabaseScreen.Hostname=${dsm_db_hostname}" >> /tmp/dsmConfiguration.properties
echo "DatabaseScreen.DatabaseName=${dsm_db_instance_name}" >> /tmp/dsmConfiguration.properties
echo "DatabaseScreen.Transport=TCP" >> /tmp/dsmConfiguration.properties
echo "DatabaseScreen.Username=${dsm_db_username}" >> /tmp/dsmConfiguration.properties
echo "DatabaseScreen.Password=${dsm_db_password}" >> /tmp/dsmConfiguration.properties
echo "AddressAndPortsScreen.ManagerPort=${dsm_managerport}" >> /tmp/dsmConfiguration.properties
echo "AddressAndPortsScreen.HeartbeatPort=${dsm_heartbeatport}" >> /tmp/dsmConfiguration.properties
echo "AddressAndPortsScreen.NewNode=true" >> /tmp/dsmConfiguration.properties
echo "UpgradeVerificationScreen.Overwrite=False" >> /tmp/dsmConfiguration.properties
echo "SecurityUpdateScreen.UpdateComponents=true" >> /tmp/dsmConfiguration.properties
echo "SecurityUpdateScreen.UpdateSoftware=true" >> /tmp/dsmConfiguration.properties
echo "SecurityUpdateScreen.Proxy=true" >> /tmp/dsmConfiguration.properties
echo "SecurityUpdateScreen.ProxyType=HTTP" >> /tmp/dsmConfiguration.properties
echo "SecurityUpdateScreen.ProxyAddress=${squid_elb_address}" >> /tmp/dsmConfiguration.properties
echo "SecurityUpdateScreen.ProxyPort=${squid_elb_port}" >> /tmp/dsmConfiguration.properties
echo "SmartProtectionNetworkScreen.EnableFeedback=false" >> /tmp/dsmConfiguration.properties
echo "SmartProtectionNetworkScreen.IndustryType=blank" >> /tmp/dsmConfiguration.properties
echo "RelayScreen.Install=True" >> /tmp/dsmConfiguration.properties
echo "RelayScreen.Proxy=true" >> /tmp/dsmConfiguration.properties
echo "RelayScreen.ProxyAddress=${squid_elb_address}" >> /tmp/dsmConfiguration.properties
echo "RelayScreen.ProxyType=HTTP" >> /tmp/dsmConfiguration.properties
echo "RelayScreen.ProxyPort=${squid_elb_port}" >> /tmp/dsmConfiguration.properties
echo "RelayScreen.Proxy=False" >> /tmp/dsmConfiguration.properties
echo "RelayScreen.AntiMalware=True" >> /tmp/dsmConfiguration.properties
echo "RelayScreen.ProxyAuthentication=False" >> /tmp/dsmConfiguration.properties
echo "Override.Automation=True" >> /tmp/dsmConfiguration.properties
echo "SoftwareUpdateScreen.Proxy=true" >> /tmp/dsmConfiguration.properties
echo "SoftwareUpdateScreen.ProxyType=HTTP" >> /tmp/dsmConfiguration.properties
echo "SoftwareUpdateScreen.ProxyAddress=${squid_elb_address}" >> /tmp/dsmConfiguration.properties
echo "SoftwareUpdateScreen.ProxyPort=${squid_elb_port}" >> /tmp/dsmConfiguration.properties
echo "AddressAndPortsScreen.ManagerAddress="$local_hostname >> /tmp/dsmConfiguration.properties

sudo chmod a+x /tmp/dsmConfiguration.properties 

#kick off trend install.
sudo sh /opt/trend/packages/dsm/default/ManagerAWS.sh -q -console -varfile /tmp/dsmConfiguration.properties >> /tmp/dsmInstall.log

##############
# Wait for API to be available
##############
until $(curl --output /dev/null --insecure --silent --head --fail https://localhost:443/rest/status/manager/ping); do
    printf 'API not up... sleeping...\n'
    sleep 30
done

##############
# Get a SID to make API Calls
##############
SID=`curl -k -H "Content-Type: application/json" -X POST "https://localhost/rest/authentication/login/primary" -d '{"dsCredentials":{"userName":"'${dsm_username}'","password":"'${dsm_password}'"}}'`

##############
# Configure Load Balancer
##############
curl -k -v -H "Content-Type: text/xml;charset=UTF-8" -H 'SOAPAction: "systemSettingSet"' "https://localhost/webservice/Manager" -d \
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Manager">'\
'<soapenv:Header/>'\
'<soapenv:Body>'\
'<urn:systemSettingSet>'\
'<urn:editableSettings>'\
'<urn:settingKey>CONFIGURATION_SYSTEMLOADBALANCERHEARTBEATHOSTNAME</urn:settingKey>'\
'<urn:settingUnit>NONE</urn:settingUnit>'\
'<urn:settingValue>'${dsm_elb_url}'</urn:settingValue>'\
'</urn:editableSettings>'\
'<urn:editableSettings>'\
'<urn:settingKey>CONFIGURATION_SYSTEMLOADBALANCERHEARTBEATPORT</urn:settingKey>'\
'<urn:settingUnit>PORT</urn:settingUnit>'\
'<urn:settingValue>'${dsm_heartbeatport}'</urn:settingValue>'\
'</urn:editableSettings>'\
'<urn:editableSettings>'\
'<urn:settingKey>CONFIGURATION_SYSTEMLOADBALANCERMANAGERHOSTNAME</urn:settingKey>'\
'<urn:settingUnit>NONE</urn:settingUnit>'\
'<urn:settingValue>'${dsm_elb_url}'</urn:settingValue>'\
'</urn:editableSettings>'\
'<urn:editableSettings>'\
'<urn:settingKey>CONFIGURATION_SYSTEMLOADBALANCERMANAGERPORT</urn:settingKey>'\
'<urn:settingUnit>PORT</urn:settingUnit>'\
'<urn:settingValue>'443'</urn:settingValue>'\
'</urn:editableSettings>'\
'<urn:editableSettings>'\
'<urn:settingKey>CONFIGURATION_SYSTEMLOADBALANCERRELAYHOSTNAME</urn:settingKey>'\
'<urn:settingUnit>NONE</urn:settingUnit>'\
'<urn:settingValue>'${dsm_elb_url}'</urn:settingValue>'\
'</urn:editableSettings>'\
'<urn:sID>'$SID'</urn:sID>'\
'</urn:systemSettingSet>'\
'</soapenv:Body>'\
'</soapenv:Envelope'\>

##############
# Configure Proxy Server
##############
curl https://localhost:443/rest/proxies --cookie "sID=$SID" --insecure -k -v -H "Content-Type: application/json" -X POST -d '{"CreateProxyRequest":{"proxy":{"name":"SQUID","description":"SquidProxy","address":"${squid_elb_address}","port":${squid_elb_port},"protocol":"http"}}}'

##############
# Restart & Wait for API to be available
##############
#sudo service dsm_s restart
#until $(curl --output /dev/null --insecure --silent --head --fail https://localhost:443/rest/status/manager/ping); do
#    printf 'API not up... sleeping...\n'
#    sleep 30
#done

SID=`curl -k -H "Content-Type: application/json" -X POST "https://localhost/rest/authentication/login/primary" -d '{"dsCredentials":{"userName":"'${dsm_username}'","password":"'${dsm_password}'"}}'`

##############
# Add Cloud Account
##############
#This isn't working yet, because the proxy cannot be set in the server.
curl https://localhost:443/rest/cloudaccounts/aws --cookie "sID=$SID" --insecure -k -v -H "Content-Type: application/json" -X POST -d '{"AddAwsAccountRequest":{"useInstanceRole":true}}'

#curl http://files.trendmicro.com/products/deepsecurity/en/10.1/Agent-amzn1-10.1.0-203.x86_64.zip -o /tmp/Agent-amzn1-10.1.0-203.x86_64.zip

#curl http://files.trendmicro.com/products/deepsecurity/en/10.1/KernelSupport-amzn1-10.1.0-222.x86_64.zip -o /tmp/KernelSupport-amzn1-10.1.0-222.x86_64.zip

##############
# Configure rsyslog
##############
sudo echo "-A INPUT -m state --state NEW -m udp -p udp --dport 1514 -j ACCEPT" >> /etc/sysconfig/iptables
sudo service iptables restart
sudo echo "$template TmplAuth, \"/var/log/%HOSTNAME%/%PROGRAMNAME%.log\"" >> /etc/rsyslog.conf
sudo echo "authpriv.*   ?TmplAuth" >> /etc/rsyslog.conf
sudo echo "*.info,mail.none,authpriv.none,cron.none   ?TmplMsg" >> /etc/rsyslog.conf
sudo echo "$ModLoad imudp" >> /etc/rsyslog.conf
sudo echo "$UDPServerRun 1514" >> /etc/rsyslog.conf
sudo service rsyslog restart

##############
# Install SumoLogic
##############
sudo wget -e use_proxy=yes -e https_proxy=https://${squid_elb_address}:${squid_elb_port} https://collectors.eu.sumologic.com/rest/download/linux/64 -O SumoCollector.sh && sudo chmod +x SumoCollector.sh && sudo ./SumoCollector.sh -q -Vsumo.token_and_url=Y3Y3eklGVVBsaXhrNDlVc3lKT2xHUUg0dTVERDA0Q0RodHRwczovL2NvbGxlY3RvcnMuZXUuc3Vtb2xvZ2ljLmNvbQ== -Vproxy.host=${squid_elb_address} -Vproxy.port={squid_elb_port}


