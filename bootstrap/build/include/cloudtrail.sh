#!/bin/bash
function cloudtrail () {
	if [[ $DEPLOY_CLOUDTRAIL == "TRUE" ]]; then
	  BANNER "Cloudtrail"
    pause "Press enter key to continue"

		cd $COMPONENTS_DIR/pcs_cloudtrail/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/cloudtrail/tfstate"

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
		echo "Cloudtrail deployment disabled in ${PARAM_FILE}."
	fi
}