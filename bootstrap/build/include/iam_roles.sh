#!/bin/bash

function terraform_apply_iam_roles () {
	if [[ $DEPLOY_IAM_ROLES == "TRUE" ]]; then
		BANNER "IAM Roles"
		echo
		pause

		cd $COMPONENTS_DIR/pcs_iam_roles/terraform

		echo "Backend: $BACKEND"
		set_backend  "aws/pcs/roles/tfstate"

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
		echo "IAM Roles deployment disabled in ${PARAM_FILE}."
	fi
}