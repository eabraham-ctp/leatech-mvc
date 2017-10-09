#!/bin/bash
# Chef Bootstrap  script for a running machine

if [ $# -lt 3 ]; then
	echo "Chef Bootstrap:"
	echo
	echo "$(basename $0) 'Chef Environment' 'Host IP' 'Chef Node Name'"
	echo "$(basename $0) ctp-pcs-sbx 127.0.0.1 localhost"
	exit 1
fi

if [ -z $CHEF_ADDRESS ]; then
	echo "CHEF_ADDRESS variable must bet set to the chef ELB"
	exit 2
fi

export CHEF_ENV=$1
IP=$2
NODE=$3
export TF_VAR_chef_user_key=~/.ssh/admin-${CHEF_ENV}.pem

DOMAIN=$(echo $CHEF_ENV | awk -F- '{print $2"-"$3"."$1}').internal
 
 ssh ec2-user@${IP} -i ~/.ssh/automation-$(echo ${CHEF_ENV} | tr [:lower:] [:upper:]).pem  sudo rm -rf /etc/chef

 knife bootstrap ec2-user@${IP} --ssh-identity-file=~/.ssh/automation-$(echo ${CHEF_ENV} | tr [:lower:] [:upper:]).pem  --no-host-key-verify  -E ${CHEF_ENV} \
 --sudo --node-ssl-verify-mode none  -r "role[base]"  --bootstrap-proxy http://proxy.$DOMAIN:8080 \
 --bootstrap-no-proxy ".$DOMAIN,169.254.169.254" --server-url "$CHEF_ADDRESS/organizations/$CHEF_ENV" -N $NODE
