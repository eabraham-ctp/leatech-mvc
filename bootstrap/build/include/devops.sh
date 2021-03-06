#!/bin/bash

function devops () {
	if [[ $DEPLOY_DEVOPS == "TRUE" ]]; then
		BANNER "DEVOPS"


		cd $COMPONENTS_DIR/pcs_devops/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/devops/tfstate"

		terraform init
		set_terraform_environment
		
		echo "Environment: $(terraform env list|grep \*)"

		terraform_apply_or_destroy
		if [ $? -ne 0 ]; then
		  cd ..
		  echo
		  echo "ERROR: Could not complete apply, exiting"
		  exit 1
		fi
		echo "-----------------------"
		echo "     stack outputs"
		echo "-----------------------"
		terraform output | tee -a $OUTPUTS_FILE
		cd $SCRIPT_DIR
	else
		echo "DEVOPS deployment disabled in ${PARAM_FILE}."
	fi	
}