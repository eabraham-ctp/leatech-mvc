#!/bin/bash
function splunk () {
	if [[ $DEPLOY_SPLUNK == "TRUE" ]]; then
	  BANNER "Splunk Enterprise"
    pause "Press enter key to continue"

		cd $COMPONENTS_DIR/pcs_splunk/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/splunk/tfstate"

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
		echo "Splunk Enterprise deployment disabled in ${PARAM_FILE}."
	fi
}