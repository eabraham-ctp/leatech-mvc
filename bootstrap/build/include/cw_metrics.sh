#!/bin/bash

function cw_metrics () { 
	if [[ $DEPLOY_CW_METRICS == "TRUE" ]]; then
		BANNER "CloudWatch Metrics and Alarms"
		pause "Press enter key to continue"

		cd $COMPONENTS_DIR/cloudwatch_metric_alarms/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/cwmetrics/tfstate"

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
		echo "CW Metrics disabled in ${PARAM_FILE}."
	fi	
}