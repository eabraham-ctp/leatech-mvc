#!/bin/bash

function artifactory () { 
	if [[ $DEPLOY_ARTIFACTORY == "TRUE" ]]; then
		BANNER "Artifactory Server"
		pause "Press enter key to continue"

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
