#!/bin/bash
function check_keypair () {

	# Check if the key exists
	KEY_FINGERPRINT=$(aws ec2 describe-key-pairs --profile ${AWS_PROFILE} --filters "Name=key-name,Values=${TF_VAR_conn_key_name}" --region=${REGION} | ${JQ_BINARY} '.KeyPairs[].KeyFingerprint' -r)

	# Create private key if the key does not exists
	if [[ -z $KEY_FINGERPRINT ]]; then
		echo Key-Pair is missing, creating key
		cd $COMPONENTS_DIR/account_global/initial_key/
		set_backend
		./create_key.sh
	else
		echo
		echo "The Key-Pair $TF_VAR_conn_key_name exists"
		echo "with the fingerprint - $KEY_FINGERPRINT"
		echo 
	fi
}
