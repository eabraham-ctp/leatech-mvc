
#!/bin/bash

function create_general_kms () {
	echo
	echo "KMS_GENERAL_KEY: $KMS_GENERAL_KEY"
	echo "KMS_AMI_KEY:     $KMS_AMI_KEY"
	# Currently there is an open issue that kms are regenerated every time so we try and work round it
	if [[ -z $KMS_GENERAL_KEY ]] || [[ -z $KMS_AMI_KEY ]]; then
		BANNER "KMS keys"

		cd $COMPONENTS_DIR/pcs_kms/terraform

		echo "Backend: $BACKEND"
		set_backend  "aws/pcs/kms/tfstate"

		# Work round to try and stop the keys regnerating on each run
		KMS_GENERAL_KEY=$(terraform output pcs_general_kms | grep  '[0-9a-z]*-[0-9a-z]*-[0-9a-z]*-[0-9a-z]*-[0-9a-z]*' 2> /dev/null)
		KMS_AMI_KEY=$(terraform output pcs_ami_kms | grep '[0-9a-z]*-[0-9a-z]*-[0-9a-z]*-[0-9a-z]*-[0-9a-z]*' 2> /dev/null)
		if [[ -z $KMS_GENERAL_KEY ]] || [[ -z $KMS_AMI_KEY ]]; then

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

			export KMS_AMI_KEY=$(terraform output pcs_ami_kms)
			
			export TF_VAR_kms_ami_key=$(terraform output pcs_ami_kms)
			export TF_VAR_kms_general_key=$(terraform output pcs_general_kms)
			export TF_VAR_kms_cloudtrail_key=$(terraform output pcs_cloudtrail_kms)

		fi
		cd $SCRIPT_DIR
	else
		echo "KMS keys already exists"
	fi
}
