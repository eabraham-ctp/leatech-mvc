#!/bin/bash

function route53 () { 
	if [[ $DEPLOY_ROUTE53 == "TRUE" ]]; then
		BANNER "Route53 Zone"

		pause "Press enter key to continue"
	    # Verify that the service subnets are set - this will require some work around #TECHDEBT there are nicer ways to do this
		if [[ -z ${TF_VAR_vpc_id} ]]; then
			cd $COMPONENTS_DIR/pcs_network/terraform
			export TF_VAR_vpc_id=$(terraform output vpc_id)
		fi
		
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