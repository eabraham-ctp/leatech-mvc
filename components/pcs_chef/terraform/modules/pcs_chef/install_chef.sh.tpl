#!/bin/bash
#TECHDEBT shared code for proxy and no proxy
# Use our proxy if available
if [ $1 != "no-proxy" ]; then
    echo "export HTTP_PROXY=http://${squid_elb_address}/" > /etc/profile.d/proxy.sh
    echo "export http_proxy=http://${squid_elb_address}/" >> /etc/profile.d/proxy.sh
    echo "export HTTPS_PROXY=http://${squid_elb_address}/" >> /etc/profile.d/proxy.sh
    echo "export https_proxy=http://${squid_elb_address}/" >> /etc/profile.d/proxy.sh
    echo "export no_proxy=${no_proxy}" >> /etc/profile.d/proxy.sh
        
    chmod a+x /etc/profile.d/proxy.sh
    source /etc/profile.d/proxy.sh
fi

echo "Installing Chef package"
curl ${install_url} -o /tmp/chef_server.rpm
sudo rpm -ivh /tmp/chef_server.rpm