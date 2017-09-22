#!/bin/bash

function route53 () { 
	if [[ $DEPLOY_ROUTE53 == "TRUE" ]]; then
		BANNER "Route53 Zone"
		pause "Press enter key to continue"

		cd $COMPONENTS_DIR/pcs_route53/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/route53/tfstate"

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
		echo "Route53 disabled in ${PARAM_FILE}."
	fi	
}