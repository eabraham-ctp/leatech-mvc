#!/bin/bash
function check_automation_bucket () {
	BANNER "S3 bucket"
	
	if ! aws s3api get-bucket-location --bucket ${TF_VAR_backend_bucket_name} --profile=$AWS_PROFILE > /dev/null 2>&1; then
		echo " The backend bucket does not exist, creating"
		cd ${COMPONENTS_DIR}/pcs_s3

		terraform init
		set_terraform_environment
		terraform_apply_or_destroy

		if [ $? -ne 0 ]; then
		  cd ..
		  echo
		  echo " ERROR: Could not complete apply, exiting"
		  exit 1
		fi
		echo "-----------------------"
		echo "     stack outputs"
		echo "-----------------------"
		terraform output | tee -a $OUTPUTS_FILE 
		cd ${SCRIPT_DIR}
	else
		echo " Backend bucket already exists"
	fi
	if [[ $BACKEND != "consul" ]]; then
		export BACKEND="s3"
	fi
	echo " Backend set to $BACKEND"
}