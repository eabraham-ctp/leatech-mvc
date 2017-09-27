#!/bin/bash

function terraform_directory_service () {
	if [[ $DEPLOY_DIRECTORY_SERVICE == "TRUE" ]]; then
		BANNER "AWS Directory Service"
		echo
		pause

		cd $COMPONENTS_DIR/pcs_directory/terraform

		echo "Backend: $BACKEND"
		set_backend  "aws/pcs/directory/tfstate"

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
		# terraform output | tee -a $OUTPUTS_FILE # IAM roles has no outputs
		# disconnect_from_openvpn

		cd $SCRIPT_DIR
	else
		echo "AWS Directory Service deployment disabled in ${PARAM_FILE}."
	fi
}