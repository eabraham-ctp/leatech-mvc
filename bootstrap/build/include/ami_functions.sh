#!/bin/bash

function create_base_ami ()
{
	if [[ $(aws ec2 describe-images --image-ids "$TF_VAR_ami_id" --profile $AWS_PROFILE --region=${REGION} | grep -c ImageId 2> /dev/null ) == 0 ]]; then
		BANNER  "BaseAMI"
		pause  "Press enter key to continue"
		if [[ -z $ENV_AMI_ID ]]; then
			PACKER_LOG_FILE="${OUTPUTS_FILE}_packer"
			if [[ -z ${KMS_AMI_KEY} ]]; then
				cd $COMPONENTS_DIR/pcs_kms/terraform
				export KMS_AMI_KEY="$(terraform output pcs_ami_kms)" 
			fi
			cd $COMPONENTS_DIR/pcs_packer
 
			if [[ -z $DEFAULT_VPC_ID ]]; then
				DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --region=${REGION} --query "Vpcs[0].VpcId" --output text)
			fi
			if [[ -z $DEFAULT_SUBNET_ID ]]; then
				DEFAULT_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC_ID" --region=${REGION}  --query "Subnets[0].SubnetId" --output text)
			fi
			echo Default VPC:    $DEFAULT_VPC_ID
			echo Default subnet: $DEFAULT_SUBNET_ID
			echo KMS key arn:    $KMS_AMI_KEY

			if [[ -z $DEFAULT_VPC_ID ]] || [[ -z $DEFAULT_SUBNET_ID ]] || [[ -z $KMS_AMI_KEY ]]; then
				echo "You need to set DEFAULT_VPC_ID and DEFAULT_SUBNET_ID as they could not be computed"
				exit 10
			else
				./create_image.sh rhel73 ${REGION} ${DEFAULT_VPC_ID} ${DEFAULT_SUBNET_ID} ${KMS_AMI_KEY} | tee -a ${PACKER_LOG_FILE} 
				EXIT=$?
				if [ $EXIT -gt 0 ]; then
					echo AMI build failed
					exit $EXIT
				else
					export ENV_AMI_ID=$(tail -n1 ${PACKER_LOG_FILE}|awk '{print $2}')
					echo "AMI: ${ENV_AMI_ID}"
					echo '#### Remove any duplicates only the last entry for AMI is used'
					echo "export ENV_AMI_ID=\"$ENV_AMI_ID\" " >> ${PARAM_FILE}
					echo '########################'
				fi
				pause "packer complete, press ENTER to continue"
			fi
		else
			echo "AMI already defined, skipping"
		fi
		pause
        export TF_VAR_ami_id=$ENV_AMI_ID
	fi
}

function create_workstation_ami ()
{
	if [[ $(aws ec2 describe-images --image-ids "$TF_VAR_workstation_ami_id" --profile $AWS_PROFILE --region=${REGION} | grep -c ImageId 2> /dev/null ) == 0 ]]; then
		echo
		echo -en "$ACTION the "
		BANNER  "BaseAMI"
		pause  "Press enter key to continue"
		if [[ -z $ENV_WORKSTATION_AMI_ID ]]; then
			PACKER_LOG_FILE="${OUTPUTS_FILE}_packer"
			if [[ -z ${KMS_AMI_KEY} ]]; then
				cd $COMPONENTS_DIR/pcs_kms/terraform
				export KMS_AMI_KEY="$(terraform output pcs_ami_kms)" 
			fi
			cd $COMPONENTS_DIR/pcs_packer
 
			if [[ -z $DEFAULT_VPC_ID ]]; then
				DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --region=${REGION} --query "Vpcs[0].VpcId" --output text)
			fi
			if [[ -z $DEFAULT_SUBNET_ID ]]; then
				DEFAULT_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$DEFAULT_VPC_ID" --region=${REGION}  --query "Subnets[0].SubnetId" --output text)
			fi
			echo Default VPC:    $DEFAULT_VPC_ID
			echo Default subnet: $DEFAULT_SUBNET_ID
			echo KMS key arn:    $KMS_AMI_KEY

			if [[ -z $DEFAULT_VPC_ID ]] || [[ -z $DEFAULT_SUBNET_ID ]] || [[ -z $KMS_AMI_KEY ]]; then
				echo "You need to set DEFAULT_VPC_ID and DEFAULT_SUBNET_ID as they could not be computed"
				exit 10
			else
				./create_image.sh rhel73-workstation ${REGION} ${DEFAULT_VPC_ID} ${DEFAULT_SUBNET_ID} ${KMS_AMI_KEY} | tee -a ${PACKER_LOG_FILE} 
				EXIT=$?
				if [ $EXIT -gt 0 ]; then
					echo AMI build failed
					exit $EXIT
				else
					export ENV_WORKSTATION_AMI_ID=$(tail -n1 ${PACKER_LOG_FILE}|awk '{print $2}')
					echo "Workstartion AMI: ${ENV_WORKSTATION_AMI_ID}"

					cp ${PARAM_FILE} $SCRIPT_DIR/environments/backup/${ORG}-${GROUP}-${ENV}.$(date +%s)
					cat ${PARAM_FILE} | grep -v "ENV_WORKSTATION_AMI_ID" > /tmp/${ORG}-${GROUP}-${ENV}.tmp
					mv /tmp/${ORG}-${GROUP}-${ENV}.tmp ${PARAM_FILE}
					echo "export ENV_WORKSTATION_AMI_ID=\"$ENV_WORKSTATION_AMI_ID\" " >> ${PARAM_FILE}
				fi
				pause "packer complete, press ENTER to continue"
			fi
		else
			echo "AMI already defined, skipping"
		fi
		pause
        export TF_VAR_workstation_ami_id=$ENV_WORKSTATION_AMI_ID
	fi
}