#!/bin/bash -xv

yum -y update
yum -y install squid httpd-tools zip unzip 

# Unpleasant work around until we have AWS cli installed -  Byron
curl https://bootstrap.pypa.io/get-pip.py | python
pip install awscli
export AWS_DEFAULT_REGION=${region}

aws s3 cp s3://${backend_bucket_name}/${squid_conf_prefix}/squid.conf /etc/squid/squid.conf
aws s3 cp s3://${backend_bucket_name}/${squid_conf_prefix}/allowed_sites /etc/squid/allowed_sites
aws s3 cp s3://${backend_bucket_name}/${squid_conf_prefix}/squid-logrotate.conf /etc/logrotate.d/squid

service squid restart
chkconfig squid on

service squid restart		
