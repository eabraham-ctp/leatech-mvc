#!/bin/bash

function terraform_chef () { 
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
		cd $SCRIPT_DIR
	else
		echo "Chef disabled in ${PARAM_FILE}."
	fi	
}