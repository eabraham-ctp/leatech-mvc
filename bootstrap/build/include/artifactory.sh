#!/bin/bash

function artifactory () { 
	if [[ $DEPLOY_ARTIFACTORY == "TRUE" ]]; then
		BANNER "Artifactory Server"
		pause "Press enter key to continue"


		# Jenkins is built via a Chef server we need to make sure that the Chef is prepared to work in the kitchen we use the bash function chef_load
		cd $COMPONENTS_DIR/pcs_chef/terraform #TECHDEBT this all horrid needs Consul and Vault
	    export CHEF_ADDRESS="https://$(terraform output chef_elb_address)"
	    export CHEF_ENV=$CHEF_ENVIRONMENTS

		chef_knife # Configures our knife.rb file
		knife ssl fetch # Cache SSL cert
		
	    cd $COMPONENTS_DIR/pcs_artifactory/chef/cookbooks/pcs_artifactory
	    berks install
	    berks upload

		cd $COMPONENTS_DIR/pcs_artifactory/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/artifactory/tfstate"

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
