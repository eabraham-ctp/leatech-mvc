#!/bin/bash

function terraform_app () { 
	BANNER "App Stacks"
	pause "Press enter key to continue"
		
	cd $COMPONENTS_DIR/pcs_rds_app/terraform

	echo "Backend: $BACKEND"
	set_backend "aws/pcs/rdsapp/tfstate"

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

}