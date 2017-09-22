#!/bin/bash
# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time resources for Bootstrap Process
# Encrypted AMI
# Creates a KMS Key to encrypt EBS volumes used during the bootstrap process.

# Pass OS type and region. Supported OS types are:
#   * ubuntu1604
#   * rhel73
# VPC and subnet are optional; if not specified, will use the default VPC for the region
# Usage ./create_image.sh <os> <region> [vpc-id] [subnet-id] [KMS-key-id]
# Example ./create_image.sh ubuntu1604 us-east-2


#TECHDEBT this script is poor in the extreme

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -lt 3 ]; then 
  echo "create_image.sh <os> <region> [vpc-id] [subnet-id] [KMS-key-id]"
  exit 10
fi


if [ -z "$3" ]; then
  vpc_id="$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --region $2)"
else
  vpc_id=$3
fi

if [ -z "$4" ]; then
  subnet_id="$(aws ec2 describe-subnets --filters Name=vpc-id,Values=${vpc_id//\"/} --region $2 --query 'Subnets[0].SubnetId')"
else
  subnet_id=$4
fi

export OS=$1

case $OS in
  ubuntu1604)
    echo "Deprecated"
    exit 14
    packer_manifest="ubuntu1604x64.json"
    ;;
  rhel73)
    packer_manifest="rhel73x64.json"
    install_script="install.sh"
    ami_use="base_ami"
    ;;
  CIS-rhel73)
    packer_manifest="CIS-rhel73x64.json"
    install_script="install.sh"
    ami_use="base_ami"
    ;;
  rhel73-workstation)
    packer_manifest="rhel73x64.json"
    install_script="workstation.sh"
    ami_use="workstation"
    ;;
  CIS-rhel73-workstation)
    packer_manifest="CIS-rhel73x64.json"
    install_script="workstation.sh"   
    ami_use="workstation"
    ;;    
  CIS-Centos72-workstation)
    packer_manifest="CIS-Centos72.json"
    install_script="workstation.sh"   
    ami_use="workstation"
    ;;
  *)
    echo "Unsupported OS type $1"
    exit 11
    ;;
esac


kms_key_id=$5

cd $SCRIPT_DIR/base_image
if [ ! -f /var/tmp/chef.rpm ]; then
  curl -o /var/tmp/chef.rpm https://packages.chef.io/files/stable/chef/13.3.42/el/7/chef-13.3.42-1.el7.x86_64.rpm  #TECHDEBT
fi

packer build \
-var "instance_type=t2.medium" \
-var "aws_region=$2" \
-var "subnet_id=${subnet_id//\"/}" \
-var "vpc_id=${vpc_id//\"/}" \
-var "user_data_text_file=user_data" \
-var "build_number=$(date +%y%m%d%H%M)" \
-var "kms_key_id=${kms_key_id}" \
-var "install_script=${install_script}" \
-var "ami_use=${ami_use}" \
$packer_manifest
if [ $? -gt 0 ]; then
  echo build failed
  exit 11
fi
cd ..
