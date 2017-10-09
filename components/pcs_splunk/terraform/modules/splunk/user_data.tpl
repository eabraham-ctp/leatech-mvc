#!/bin/bash

#Set script debug flag so that we see what happens
set -x

#Send debugging info to this log, so that we can easily debug it
exec 1> /var/tmp/mylog 2>&1

LOCALIP="$(hostname -I | xargs)"
NEW_PASSWORD="${ui_password}"
AUTH="admin:$NEW_PASSWORD"
SEARCH_ASG="${searchASG}"
INDEXER_ASG="${indexerASG}"
REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
ROLE="${role}"

ids=""
while [ "$ids" = "" ]; do
  ids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $INDEXER_ASG --region $REGION --query AutoScalingGroups[].Instances[].InstanceId --output text)
  sleep 1
done
for ID in $ids;
do
    IP=$(aws ec2 describe-instances --instance-ids $ID --region $REGION --query Reservations[].Instances[].PrivateIpAddress --output text)
    SERVER="$IP:9997"
    [ "$INDEXERS" = "" ] && INDEXERS=$SERVER || INDEXERS="$INDEXERS,$SERVER"
done

#get searchhead cluster members
ids=""
while [ "$ids" = "" ]; do
  ids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $SEARCH_ASG --region $REGION --query AutoScalingGroups[].Instances[].InstanceId --output text)
  sleep 1
done
for ID in $ids;
do
    IP=$(aws ec2 describe-instances --instance-ids $ID --region $REGION --query Reservations[].Instances[].PrivateIpAddress --output text)
    MEMBER="https://$IP:8089"
    [ "$SEARCHERS" = "" ] && SEARCHERS=$MEMBER || SEARCHERS="$SEARCHERS,$MEMBER"
done

cat <<EOF | tee -a /home/ec2-user/.bashrc
export SPLUNK_HOME="/opt/splunk"
alias splunk="sudo -u splunk /opt/splunk/bin/splunk"
export REGION="$REGION"
export SEARCH_ASG="${searchASG}"
export INDEXER_ASG="${indexerASG}"
export INDEXERS="$INDEXERS"
export SEARCHERS="$SEARCHERS"
export MEMBER="$MEMBER"
export ROLE="$ROLE"
EOF
source /home/ec2-user/.bashrc

# Update secret file
echo "${secret}" > ./splunk.secret
sudo mv -f ./splunk.secret /opt/splunk/etc/auth/splunk.secret
sudo chown -R splunk:splunk /opt/splunk/etc/auth/splunk.secret

# Update hostname
hostname splunk-${role}-`hostname`
echo `hostname` > /etc/hostname
sed -i 's/localhost$/localhost '`hostname`'/' /etc/hosts

# Change splunk UI user password
sudo /opt/splunk/bin/splunk enable boot-start -user splunk --accept-license --answer-yes
sudo -u splunk mv /opt/splunk/etc/passwd /opt/splunk/etc/passwd.bak
sudo -u splunk mkdir -p /opt/splunk/.splunk
sed -i 's/force-change-pass true//' /etc/init.d/splunk
sudo -u splunk /opt/splunk/bin/splunk edit user admin -password $NEW_PASSWORD -auth admin:changeme
sudo -u splunk touch /opt/splunk/etc/.ui_login

# Create local config files
sudo -u splunk mkdir -p /opt/splunk/etc/system/local

cat <<EOF | sudo -u splunk tee -a /opt/splunk/etc/system/local/deploymentclient.conf
${deploymentclient_conf_content}
EOF

cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/web.conf
${web_conf_content}
EOF

cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/serverclass.conf
${serverclass_conf_content}
EOF

cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/server.conf
${server_conf_content}
EOF

if [ "$ROLE" = "indexer" ]; then
  #Enable the receiver
  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/inputs.conf
    [splunktcp://9997]
    disabled = 0
EOF
fi

if [ "$ROLE" = "searchhead" ]; then
  echo "mgmt_uri = https://$LOCALIP:8089" | sudo -u splunk tee -a /opt/splunk/etc/system/local/server.conf

  #Configure apps
  sudo -u splunk mkdir -p /opt/splunk/etc/users/admin/user-prefs/local
  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/users/admin/user-prefs/local/user-prefs.conf
  [general]
  eai_app_only = False
  eai_results_per_page = 25
  default_namespace = splunk_app_aws
EOF
fi

#HEAVY FORWARDER SERVER
if [ "$ROLE" = "forwarder" ]; then

  #Configure Forwarding to the Indexers
  cat <<EOF | sudo -u splunk tee -a /opt/splunk/etc/system/local/outputs.conf
  [tcpout]
  defaultGroup = splunk-aws-indexer-cluster
  indexAndForward = false
  forwardedindex.filter.disable = true

  [tcpout:splunk-aws-indexer-cluster]
  server = $INDEXERS
  autoLB = true
EOF

  #Enable the Heavy Forwarder
  sudo -u splunk mkdir -p /opt/splunk/etc/apps/SplunkForwarder/local
  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/apps/SplunkForwarder/local/app.conf
  [install]
  state = enabled
EOF

  #Install the AWS Add-on
  cd /opt/splunk/etc/apps
  sudo -u splunk tar -zxf /var/tmp/aws-app.tgz

  cd /opt/splunk/etc/apps
  sudo -u splunk tar -zxf /var/tmp/aws-addon.tgz

  sudo -u splunk mkdir -p /opt/splunk/etc/apps/Splunk_TA_aws/local
  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/apps/Splunk_TA_aws/local/aws_account_ext.conf
  ${account_conf}
EOF
  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/apps/Splunk_TA_aws/local/inputs.conf
  ${inputs_conf}
EOF
fi

#MASTER NODE & DEPLOYER SERVER
if [ "$ROLE" = "master" ]; then
  cat <<EOF | sudo -u splunk tee -a /opt/splunk/etc/system/local/server.conf
  ${deployer_conf}
EOF

  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/deploymentclient.conf
  [deployment-client]
  serverRepositoryLocationPolicy = rejectAlways
  repositoryLocation = /opt/splunk/etc/master-apps
EOF

  #Deploy AWS AddOn to searchheads
  cd /opt/splunk/etc/shcluster/apps
  sudo -u splunk tar -zxf /var/tmp/aws-addon.tgz

  #Turn off AWS Add-on Visibility on searchheads
  sudo -u splunk mkdir -p /opt/splunk/etc/shcluster/apps/Splunk_TA_aws/local
  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/shcluster/apps/Splunk_TA_aws/local/app.conf
  [ui]
  is_visible =  false
EOF

  #Configure AWS App
  cd /opt/splunk/etc/shcluster/apps
  sudo -u splunk tar -zxf /var/tmp/aws-app.tgz
  sudo -u splunk mkdir -p /opt/splunk/etc/shcluster/apps/splunk_app_aws/local

  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/shcluster/apps/splunk_app_aws/local/macros.conf
  [aws-cloudtrail-index]
  definition = ((index="main" OR index="aws-cloudtrail") OR index="default")
EOF

  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/shcluster/apps/splunk_app_aws/local/savedsearches.conf
  [CloudTrail EventName Generator]
  enableSched = 1

  [AWS Billing - Account Name]
  enableSched = 1

  [Config: Topology Daily Snapshot Generator]
  enableSched = 1

  [Config: Topology History Appender]
  enableSched = 1

  [Config: Topology Monthly Snapshot Generator]
  enableSched = 1

  [Config: Topology Playback Appender]
  enableSched = 1

  [AWS Description - Tags]
  enableSched = 1

  [AWS Config - Tags]
  enableSched = 1

  [AWS Description - CloudFront Edges]
  enableSched = 1

  [CloudWatch: Topology CPU Metric Generator]
  enableSched = 1

  [CloudWatch: Topology Disk IO Metric Generator]
  enableSched = 1

  [CloudWatch: Topology Network Traffic Metric Generator]
  enableSched = 1

  [CloudWatch: Topology Volume IO Metric Generator]
  enableSched = 1

  [CloudWatch: Topology Volume Traffic Metric Generator]
  enableSched = 1

  [Billing: Topology Billing Metric Generator]
  enableSched = 1

  [Amazon Inspector: Topology Amazon Inspector Recommendation Generator]
  enableSched = 1

  [Config Rules: Topology Config Rules Generator]
  enableSched = 1

  [Billing: Detailed Reports List]
  enableSched = 1
  realtime_schedule = 0

  [Insights: EBS]
  enableSched = 1

  [Insights: EIP]
  enableSched = 1

  [Insights: ELB]
  enableSched = 1

  [VPC Flow Logs Summary Generator - Dest IP]
  enableSched = 1

  [VPC Flow Logs Summary Generator - Dest Port]
  enableSched = 1

  [VPC Flow Logs Summary Generator - Src IP]
  enableSched = 1
EOF

  cat <<EOF | sudo -u splunk tee /opt/splunk/etc/shcluster/apps/splunk_app_aws/local/outputs.conf
  [indexAndForward]
  index = false

  [tcpout]
  defaultGroup = my_search_peers
  forwardedindex.filter.disable = true
  indexAndForward = false

  [tcpout:my_search_peers]
  server=$INDEXERS
EOF

  #deploy apps/configuration to searchers
  #sudo -u splunk /opt/splunk/bin/splunk apply shcluster-bundle --answer-yes -target $MEMBER -auth $AUTH

  #aws addon indexes summary configuration
  sudo -u splunk touch $SPLUNK_HOME/etc/master-apps/_cluster/local/indexes.conf
  sudo -u splunk cat /opt/splunk/etc/shcluster/apps/splunk_app_aws/default/indexes.conf | \
    sudo -u splunk tee $SPLUNK_HOME/etc/master-apps/_cluster/local/indexes.conf

  #deploy apps/configuration to indexers
  #sudo -u splunk /opt/splunk/bin/splunk apply cluster-bundle --answer-yes -auth $AUTH
fi

# Start splunk
sudo -u splunk /opt/splunk/bin/splunk start --accept-license --answer-yes

function cmd(){
   command=$1
   for i in $(seq 1 30); do
     sudo -u splunk /opt/splunk/bin/splunk $@
     if [ $? -eq 0 ]; then
       break
     else
       sleep 2
     fi
   done
}

if [ "$ROLE" = "searchhead" -a  "$MEMBER" = "https://$(hostname -I | xargs):8089" ]; then
  #Set Searchhead captain to a searchhed cluster member
  cmd bootstrap shcluster-captain -servers_list "$SEARCHERS" -auth $AUTH
fi

if [ "$ROLE" = "master" ]; then
  cmd apply cluster-bundle --answer-yes -auth $AUTH
  cmd apply shcluster-bundle --answer-yes -target $MEMBER -auth $AUTH
fi