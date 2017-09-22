#!/bin/bash

#TECHDEBT one function for all APPS
function talend_stack () { 
	BANNER "Talend App Stack"
	pause "Press enter key to continue"
		
	cd $COMPONENTS_DIR/pcs_talend/terraform

	echo "Backend: $BACKEND"
	set_backend "aws/pcs/talend/tfstate"

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