#!/bin/bash

function upload_private_keys_to_bucket () {
	BANNER "Uploading keys"
	local KEY_PATH="automation/keys"
	local LOCAL_KEY_MD5=$( openssl dgst -md5 ${TF_VAR_conn_private_key} | awk '{print $2}')

	# check if the keys exist in the bucket
	local S3KEY=$(aws s3api head-object --bucket ${BACKEND_BUCKET} --key "${KEY_PATH}/${TF_VAR_conn_key_name}.pem" --profile=${ORG}-${GROUP}-${ENV} 2> /dev/null) 

	if [[ $S3KEY == *"ETag"* ]]; then
		# Key already exist
		local S3_KEY_MD5=$(echo $S3KEY | $JQ_BINARY -r .ETag | sed s/\"//g)
	else
		# key file is missing
		PUT_KEY=$(aws s3api put-object --bucket ${BACKEND_BUCKET} --key "${KEY_PATH}/${TF_VAR_conn_key_name}.pem" --body ${TF_VAR_conn_private_key} --profile=${ORG}-${GROUP}-${ENV} )
		local S3_KEY_MD5=$(echo -e $PUT_KEY | $JQ_BINARY -r .ETag | sed s/\"//g)
	fi

	# compare s3 key to local key
	# Verify the ETag is identical to the local file MD5sum
	if [[ "${S3_KEY_MD5}" == "${LOCAL_KEY_MD5}" ]]; then
		echo "  SSH key uploaded to S3"
	else
		echo "  Somthing went wrong with the key upload, md5 hashes differ"
		exit 20
	fi
}

function write_ssh_key_to_vault ()
{
    KEYNAME=$1
    KEYFILE=$2

	if [[ -z ${VAULT_ADDR} ]]; then
		cd $COMPONENTS_DIR/pcs_vault/terraform
		export VAULT_ADDR="$(terraform output vault_url)"
	fi
	
	export VAULT_ROOT_TOKEN=$(cat $VAULT_INIT_FILE| grep "Initial Root Token"|awk '{print $4}')
	vault auth $VAULT_ROOT_TOKEN
	VAULT_PATH=$(echo secret/aws/config/secret/${ORG}/${GROUP}/${ENV} | tr '[:upper:]' '[:lower:]')
	echo "Uploading $KEY to vault at $VAULT_PATH"
	$VAULT_BINARY write ${VAULT_PATH}/${KEYNAME} value=@${KEYFILE}
}