#!/bin/bash

function chef () { 
	if [[ $DEPLOY_CHEF == "TRUE" ]]; then
		BANNER "Chef Server"
		pause "Press enter key to continue"

		cd $COMPONENTS_DIR/pcs_chef/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/chef/tfstate"

		terraform init
		set_terraform_environment
		
		echo "Environment: $(terraform env list|grep \*)"

		terraform_apply_or_destroy
		if [ $? -ne 0 ]; then
		  cd ..
		  echo
		  echo "ERROR: Could not complete $ACTION, exiting"
		  exit 1
		fi
		echo "-----------------------"
		echo "     stack outputs"
		echo "-----------------------"
		terraform output | tee -a $OUTPUTS_FILE


		CHEF_ADDRESS=$(terraform output chef_address)
		CHEF_ADMIN_USER=$(terraform output admin_username)
		ADMIN_KEY=${CHEF_ADMIN_USER}-$(echo ${ORG}-${GROUP}-${ENV}| tr '[:upper:]' '[:lower:]').pem
		VALIDATOR_KEY=$(echo ${ORG}-${GROUP}-${ENV}| tr '[:upper:]' '[:lower:]')-validator.pem
		if [ ! -z $CHEF_ADDRESS ]; then
			if [ ! -f ~/.ssh/$ADMIN_KEY ]; then
			    scp -i $TF_VAR_conn_private_key ec2-user@$CHEF_ADDRESS:$ADMIN_KEY ~/.ssh
			fi

			if [ ! -f  ~/.ssh/$VALIDATOR_KEY ]; then
				scp -i $TF_VAR_conn_private_key ec2-user@$CHEF_ADDRESS:$VALIDATOR_KEY  ~/.ssh
			fi

			if [ -f ~/.ssh/$ADMIN_KEY ] && [ -f  ~/.ssh/$VALIDATOR_KEY ] && [ $DEPLOY_VAULT == "TRUE"  ]; then	
				echo "Writing keys to Vault"
				write_ssh_key_to_vault chef_admin_key ~/.ssh/$ADMIN_KEY
				write_ssh_key_to_vault chef_org_key ~/.ssh/$VALIDATOR_KEY
			else
				echo "Vault disabled or keys failed to failed to fetch"
			fi
		fi
		cd $SCRIPT_DIR
	else
		echo "Chef disabled in ${PARAM_FILE}."
	fi	
}