#!/bin/bash

 CHEF_SERVER=$1
 ENV=$2
 IP=$3
 NODE=$4
 

DOMAIN=$(echo vmdb-pcs-sbx | awk -F- '{print $2"-"$3"."$1}').internal
 
# knife ssl fetch --server-url "https://$CHEF_SERVER/organizations/$ENV"
  ssh ec2-user@${IP} -i ~/.ssh/automation-$(echo ${ENV} | tr [:lower:] [:upper:]).pem  sudo rm -rf /etc/chef
 knife bootstrap ec2-user@${IP} --ssh-identity-file=~/.ssh/automation-$(echo ${ENV} | tr [:lower:] [:upper:]).pem  --no-host-key-verify  -E ${ENV} \
 --sudo --node-ssl-verify-mode none  -r "role[base]"  --bootstrap-proxy http://proxy.$DOMAIN:8080 \
 --bootstrap-no-proxy "chef.$DOMAIN,trend.$DOMAIN,169.254.169.254" --server-url "https://$CHEF_SERVER/organizations/$ENV" -N $NODE

