#!/bin/bash

# coding standards
# ================
# bash variables should be in upper case
# Terraform keys should be in the form of TF_VAR_<var_name_in_lower_case>
#

# Set the constants:
export SCRIPT_DIR=$(pwd)
export BASE_DIR=$(dirname $(dirname $SCRIPT_DIR))
export COMPONENTS_DIR="${BASE_DIR}/components"
export SUDO_BINARY=$(which sudo)
export TIMESTAMP=$(date +"%Y%m%d_%H%M")
export OUTPUTS_FILE="$SCRIPT_DIR/logs/output_$TIMESTAMP"
export VERBOSE=false
for file in include/*.sh; do
	source ${file}
done
source environments/COMMON

# General Variables
export ORG="CTP"
export GROUP="GROUP"
export ENV="SBX"
export COMPONENTS="all"
export ACTION="Building"
export REGION="eu-west-1"

# Usage:
show_help(){
cat << EOF
Usage: ${0##*/} [-hv] [-f OUTFILE] [FILE]...

Deploy the MVC components based on the Terraform scripts and provided environment.
Make sure to setup the AWS profile to match the profile in the 

  --org     -o=<STRING>    Name for the Organization  Default: CTP 
  --group   -g=<STRING>    Name for the Group         Default: PCS
  --env     -e=<STRING>    Name for the environment   Default: SBX
            -v             Verbose output
  -c=component             Name of the component to be deployed Default: all
                           options: iam, vpc, consul, vault, vaultnodes
  -m=mode                  action to be performed by terraform apply,plan,refresh,destroy,etc   
  --destroy                Destroys instead of building 
  --forces3                Ignore consul and use S3 as a backend

Environments files should be located in the environments directory under the scripts dir:
${SCRIPT_DIR}/environments

** Note **
AWS cli and boto profiles should be set to the organization name - i.e. CTP-PCS-SBX

EOF
}


check_dependencies

# by default the script will deploy the SBX environment. Provide --group and/or --env to deploy elsewhere

#Unset the default AWS variables to avoid running in the wrong account
unset AWS_ACCESS_KEY_ID 
unset AWS_SECRET_ACCESS_KEY

# get the options

for i in "$@"
do
	case $i in
		-o=*|--org=*)
			export ORG="${i#*=}"
			;;
		-g=*|--group=*)
			export GROUP="${i#*=}"
			;;
		-e=*|--env=*)
			export ENV="${i#*=}"
			;;
		-c=*)
			export COMPONENTS="${i#*=}"
			;;
		-m=*)
			export APPLYMODE="${i#*=}"
			;;			
		-a)
			echo "running in AUTO mode (no pause)"
			export DISABLE_PAUSE=true
			;;
		-v)
			export VERBOSE=true
			# set -x
			;;
		--destroy) #TECHDEBT will be deprecated
			export ACTION="Destroying"
			BANNER "Set to destroy!!!"
			pause "Will be deprecated consider using -m=destroy --  Press enter key to continue"
		    ;;
		--forces3)
			export FORCES3="true"
			;;
		-h|--help) 
			show_help
			exit 0
			;;
	esac
done

clear

BANNER "MVC Bootstrap"


# set the AWS profile
export AWS_PROFILE=${ORG}-${GROUP}-${ENV}
export AWS_DEFAULT_PROFILE=${ORG}-${GROUP}-${ENV}
grep $AWS_PROFILE ~/.aws/credentials
if [[ $? -eq 1 ]]; then
	echo " AWS profile $AWS_PROFILE not configured, please set it up before running the script "
	exit
fi

echo "AWS profile: $AWS_PROFILE"
echo
export TF_VAR_aws_profile=${AWS_PROFILE}

export VPC_NAME="${ORG}-${GROUP}-${ENV}-VPC"

echo >> $OUTPUTS_FILE
echo "$(date) Deploying ${ORG}-${GROUP}-${ENV}" >> $OUTPUTS_FILE
echo "=============================================" >> $OUTPUTS_FILE

export PARAM_FILE="$SCRIPT_DIR/environments/${ORG}-${GROUP}-${ENV}"

# import the environment's parameters
if [[ -f ${PARAM_FILE} ]]; then
	source ${PARAM_FILE}
else
	echo "Parameters file ${PARAM_FILE} is missing."
	exit 1
fi

# check if consul installed:
# If the environment is not PCS, use NonProd Consul
if [ -z $FORCES3 ]; then
	export CONSUL_MASTER_IP=$(aws ec2 describe-instances --profile $CONSUL_PROFILE --region=${REGION} --filters "Name=instance-state-name,Values=running" "Name=tag-key,Values=Name" "Name=tag-value,Values=${CONSUL_PROFILE}-Consul-Primary-EC2" --query "Reservations[].Instances[].PrivateIpAddress" --output text) 
fi

if [[ -z $CONSUL_MASTER_IP  ]]; then
	echo "Consul not running, using local backend"
	export BACKEND="local"
else
	echo "Consul running, using $CONSUL_MASTER_IP as backend"
	export BACKEND="consul"
	export CONSUL_HTTP_ADDR=${CONSUL_MASTER_IP}:8500
fi
echo

# check if vault installed:
# If the environment is not PCS, use NonProd Consul
if [[ "$BACKEND_PROFILE" != "$AWS_PROFILE" ]]; then
	export VAULT_MASTER_IP=$(aws ec2 describe-instances --profile $CONSUL_PROFILE --region=${REGION} --filters "Name=instance-state-name,Values=running" "Name=tag-key,Values=Name" "Name=tag-value,Values=${CONSUL_PROFILE}-Vault-Master-EC2" --query "Reservations[].Instances[].PrivateIpAddress" --output text)
	if [ ! -z $VAULT_MASTER_IP ]; then
		echo "Setting up vault to $CONSUL_PROFILE"
		echo
		echo   VAULT_MASTER_IP: $VAULT_MASTER_IP
		export VAULT_ADDR=http://${VAULT_MASTER_IP}:8200
		export VAULT_INIT_FILE="$SCRIPT_DIR/${BACKEND_PROFILE}-vault_init.txt"
	fi
fi


########################
# Common variables, shared by many stacks
########################
# AMI to use:
export TF_VAR_ami_id=${ENV_AMI_ID}
export TF_VAR_workstation_ami_id=${ENV_WORKSTATION_AMI_ID}

# Region for AWS provider
# Can be any region, but azs must match selected region
export TF_VAR_region=${REGION}

# Name of organization/business unit #TECHDEBT this should never of been grouped!
export TF_VAR_org="${ORG}-${GROUP}"
export TF_VAR_group="${GROUP}"

export TF_VAR_vpc_name="${VPC_NAME}"

# Name of environment (NonProd, Sandbox, etc)
export TF_VAR_environment=${ENV}

export TF_VAR_conn_key_name=automation-$TF_VAR_org-$TF_VAR_environment
export TF_VAR_conn_private_key=~/.ssh/automation-$TF_VAR_org-$TF_VAR_environment.pem
export TF_VAR_conn_user_key=$TF_VAR_conn_private_key
export TF_VAR_conn_public_key=$TF_VAR_conn_private_key.pub  #TECHDEBT this name is easy to fix at least use


# The below default tags will be applied to all resources and are based on the tagging schema.
# See https://docs.google.com/document/d/1PV1ulDUhF0l-3fbK0KLLSqPI7xh325Z5RmgIETsJo_w/edit#heading=h.lb7fhb6njibj for more information
export TF_VAR_default_tags="{
  Organization      = \"${ORG}-${GROUP}\"
  ApplicationName   = \"${APPLICATIONNAME}\"
  Environment       = \"${ENV}\"
  TechnicalResource = \"${TECHNICALRESOURCE}\"
  BusinessOwner     = \"${BUSINESSOWNER}\"
}"

# Allow for more granular environments
export TERRAFORM_ENV=$(echo ${GROUP}-${ENV}|tr '[:upper:]' '[:lower:]')-$TF_VAR_region

########################
# pcs_network variables
########################

# Overall VPC CIDR range and ranges for all PCS subnets
export TF_VAR_vpc_cidr="${VPC_CIDR}"
export TF_VAR_subnet_cidrs="{
  \"DMZ\"             = \"${DMZ_SUBNETS}\",
  \"Services\"        = \"${SERVICES_SUBNETS}\",
  \"Security\"        = \"${SECURITY_SUBNETS}\",
  \"Data\"            = \"${DATA_SUBNETS}\",
  \"Workstations\"    = \"${WORKSTATIONS_SUBNETS}\"
}"

# quick and ugly fix for the services subnet name
if [[ -z $SERVICES_SUBNETS_NAME ]]; then
	export TF_VAR_services_subnets_name="Services"
else
	export TF_VAR_services_subnets_name="${SERVICES_SUBNETS_NAME}"
fi

# CIDR ranges where admin access is allowable
export TF_VAR_jumpbox_rdp_cidrs="[\"$BASTION_SUBNETS\"]"
export TF_VAR_jumpbox_ssh_cidrs="[\"$BASTION_SUBNETS\"]"

# EIP allocation id for openvpn
if [[ -z ${OPENVPN_EIP} ]]; then
	echo "Parameters file missing the Elastic IP allocation ID, will not build OpenVPN server"
else
	export TF_VAR_openvpn_eip=${OPENVPN_EIP}
	echo "openvpn_eip:           ${TF_VAR_openvpn_eip}"
fi

echo "services_subnets_name: $TF_VAR_services_subnets_name"



########################
# pcs_vault variables
########################
export TF_VAR_cluster_name="$(echo ${ORG}-${GROUP}-${ENV}-vault_pcs | tr '[:upper:]' '[:lower:]')"

# ==========================================================================================
# End Variables declaration

if $VERBOSE ; then
	echo -e "SCRIPT_FULL_PATH:        ${SCRIPT_FULL_PATH}"
    echo -e "SCRIPT_DIR:              ${SCRIPT_DIR}"
    echo -e "BASE_DIR:                ${BASE_DIR}"
    echo -e "COMPONENTS_DIR:          ${COMPONENTS_DIR}"
    echo
    echo -e "SUDO_BINARY:             ${SUDO_BINARY}"
    echo -e "TIMESTAMP:               ${TIMESTAMP}"
    echo -e "OUTPUTS_FILE:            ${OUTPUTS_FILE}"
    echo -e "VERBOSE:                 ${VERBOSE}"
	echo -e "TF_VAR_region:           ${TF_VAR_region}"
	echo -e "TF_VAR_org:              ${TF_VAR_org}"
	echo -e "TF_VAR_environment:      ${TF_VAR_environment}"
	echo -e "TF_VAR_os:               ${TF_VAR_os}"
	echo -e "TF_VAR_ssh_cidrs:        ${TF_VAR_ssh_cidrs}"
	echo -e "TF_VAR_git_key_path:     ${TF_VAR_git_key_path}"
	echo -e "TF_VAR_conn_key_name:    ${TF_VAR_conn_key_name}"
	echo -e "TF_VAR_conn_private_key: ${TF_VAR_conn_private_key}"
	echo -e "TF_VAR_conn_public_key:  ${TF_VAR_conn_public_key}"
	echo -e "TERRAFORM_ENV:           ${TERRAFORM_ENV}"
	echo -e "TF_VAR_default_tags:\n${TF_VAR_default_tags}"
	echo -e "TF_VAR_azs:              ${TF_VAR_azs}"
	echo -e "TF_VAR_vpc_cidr:         ${TF_VAR_vpc_cidr}"
	echo -e "TF_VAR_subnet_cidrs:\n${TF_VAR_subnet_cidrs}"
	echo -e "TF_VAR_domain_name_servers: ${TF_VAR_domain_name_servers}"
	echo -e "TF_VAR_vpn_conn_config:  ${TF_VAR_vpn_conn_config}"
	echo -e "TF_VAR_openvpn_user:     ${TF_VAR_openvpn_user}"
	echo -e "TF_VAR_openvpn_password: ${TF_VAR_openvpn_password}"
	echo -e "TF_VAR_jumpbox_rdp_cidrs:${TF_VAR_jumpbox_rdp_cidrs}"
	echo -e "TF_VAR_jumpbox_ssh_cidrs:${TF_VAR_jumpbox_ssh_cidrs}"
	echo
	echo -e "TF_VAR_vpc_name:${TF_VAR_vpc_name}"
	echo
	echo -e "${OPENVPN_CONFIG_FILE}"
	echo
	pause "Press enter key to continue"
fi


#######################################
# FUNCTIONS                           #
#######################################

function push_tfstate_to_consul () {
	

	# Consul can shared, environment must be set
	set_terraform_environment

	# push pcs_kms
	export BACKEND="consul"
	cd $COMPONENTS_DIR/pcs_kms/terraform
	set_backend  "aws/pcs/kms/tfstate"
	terraform init -force-copy

	# push iam_roles
	export BACKEND="consul"
	cd $COMPONENTS_DIR/pcs_iam_roles/terraform
	set_backend  "aws/pcs/roles/tfstate"
	terraform init -force-copy

	# push pcs_network
	cd $COMPONENTS_DIR/pcs_network/terraform
	set_backend  "aws/pcs/vpc/tfstate"
	terraform init -force-copy

	# push consul
	cd $COMPONENTS_DIR/pcs_consul/terraform
	set_backend  "aws/pcs/consul/tfstate"
	terraform init -force-copy	

	# push squid
	cd $COMPONENTS_DIR/pcs_squid/terraform
	set_backend  "aws/pcs/squid/tfstate"
	terraform init -force-copy	
}

################################################
#                     MAIN                     #
################################################

# Verify the automation bucket exists
if [[ -z ${BACKEND_BUCKET} ]]; then
	${lower(var.org)}-${lower(var.environment)}-${var.bucket_suffix}
fi
export TF_VAR_backend_bucket_name=${BACKEND_BUCKET}
echo Using ${TF_VAR_backend_bucket_name} as backend
export VAULT_INIT_FILE="$SCRIPT_DIR/${ORG}-${GROUP}-${ENV}-vault_init.txt"


check_automation_bucket

if [[ $COMPONENTS == "all" ]]; then
	if [ $BACKEND != "consul" ] && [ $ACTION != "Destroying" ]; then
		echo "Assuming this is the first run, "
		check_keypair
		upload_private_keys_to_bucket
		create_general_kms
		terraform_apply_iam_roles
		vpc
		create_base_ami 
		terraform_apply_squid # Squid controls all outbound access and has no pre-requisites apart from and AMI and KMS
		pause "Squid takes a couple of minutes to stand up before it can route connections press enter after waiting"
		terraform_apply_consul
		push_tfstate_to_consul
		terraform_apply_vault
        load_key_to_vault
	else
		echo "Assuming this is a rerun."
		# Simple workaround to destroy a running stack LIFO style
		if [ $ACTION != "Destroying" ]; then
			check_keypair
			upload_private_keys_to_bucket
			create_general_kms			
			create_base_ami 
			vpc
			terraform_apply_iam_roles
			terraform_apply_squid 
			terraform_apply_consul
			terraform_apply_vault
		    load_key_to_vault		
		 else
		 	BACKEND="s3" # Move our state out of Consul 
		 	terraform_apply_vault
		 	terraform_apply_consul
			terraform_apply_squid
			vpc
			terraform_apply_iam_roles
		fi
	fi
else
	case $COMPONENTS in
		iam )
			terraform_apply_iam_roles
		;;
		vpc )
			vpc
		;;
		consul )
			terraform_apply_consul
		;;
		vault )
			terraform_apply_vault
		;;
		vaultnodes )
		;;
		upload_keys )
			upload_private_keys_to_bucket
		;;
		pushstate )
			push_tfstate_to_consul
		;;
		squid )
			terraform_apply_squid
		;;
		loadkeys )
			load_key_to_vault
		;;
		devops )
			devops
		;;
		rstudio )
			terraform_app rstudio
		;;
		talend )
			talend_stack  #TECHDEBT ugly repetition of terraform_app
		;;
		kms )
			create_general_kms
		;;
		create_base_ami )
			create_base_ami
		;;
		chef )
			terraform_chef
		;;
		trend )
			trend
		;;
		route53 )
			route53
		;;
		cw_metrics )
			cw_metrics
		;;	
		cleanstate )
			clean_local_state
		;;
		gitlab )
			gitlab
		;;
		* )
			echo "The component $COMPONENTS is not recognised"
			exit
		;;
	esac
fi
echo "~~ FIN ~~"
