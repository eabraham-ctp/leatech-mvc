#!/bin/bash

function gitlab () { 
	if [[ $DEPLOY_GITLAB == "TRUE" ]]; then
		BANNER "Gitlab Server"
		pause "Press enter key to continue"

		# Gitlab is built via a Chef server we need to make sure that the Chef is prepared to work in the kitchen

		cd $COMPONENTS_DIR/pcs_chef/terraform #TECHDEBT this all horrid needs Consul and Vault
	    export CHEF_ADDRESS="https://$(terraform output chef_elb_address)"
	    export CHEF_ENV=$CHEF_ENVIRONMENTS

		chef_knife # Configures our knife.rb file
		knife ssl fetch # Cache SSL cert
		chef_load role $COMPONENTS_DIR/pcs_gitlab/chef/roles/gitlab.json

		cd $COMPONENTS_DIR/pcs_gitlab/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/gitlab/tfstate"

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
		cd $SCRIPT_DIR
	else
		echo "Gitlab disabled in ${PARAM_FILE}."
	fi	
}
