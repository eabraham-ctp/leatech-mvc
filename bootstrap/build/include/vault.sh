#!/bin/bash

function terraform_apply_vault () {
	if [[ $DEPLOY_VAULT == "TRUE" ]]; then
		BANNER  "Vault"
		pause  "Press enter key to continue"

	# 	Verify that the service subnets are set - this will require some work around #TECHDEBT use CONSUL
		if [ -z ${TF_VAR_service_subnet_ids} ]  && [ $ACTION != "Destroying" ]; then
			cd $COMPONENTS_DIR/pcs_network/terraform
			terraform output service_subnet_ids
			local subnet_ids=$(for i in $(terraform output service_subnet_ids| tr ',' ' '); do echo -n "\"$i\","; done | sed 's/.$//')
			export TF_VAR_service_subnet_ids=$(echo "[${subnet_ids}]")
			export TF_VAR_vpc_id=$(terraform output vpc_id)
		fi

		# Verify squid proxy is set #TECHDEBT optional?
		if [ -z ${TF_VAR_squid_elb_address} ] && [ $ACTION != "Destroying" ]; then
			cd $COMPONENTS_DIR/pcs_squid/terraform
			export TF_VAR_squid_elb_address=$(terraform output squid_elb_address)
			export TF_VAR_squid_elb_sg=$(terraform output squid_elb_sg)	
		fi
		
		cd $COMPONENTS_DIR/pcs_vault/terraform
		
		echo "Backend: $BACKEND"
		set_backend "aws/pcs/vault/tfstate"

		terraform init
		set_terraform_environment
		
		echo "Environment: $(terraform env list|grep \*)"

		if [[ $ACTION == "Destroying" ]]; then
			terraform destroy
		else
			terraform_apply_or_destroy
		fi

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

		if [[ $ACTION == "Building" ]]; then
			export PRIMARY_VAULT_ADDR=$(terraform output vault_url)
			export VAULT_ADDR=${PRIMARY_VAULT_ADDR}

			cd $BASE_DIR
			rm $VAULT_INIT_FILE.tmp &>/dev/null
			$VAULT_BINARY status | grep "Mode: sealed" &> /dev/null
			if [[ $? -eq 0 ]]; then
				echo "Vault is already initialized"
				echo "$($VAULT_INIT| grep Mode)"
			else
				VAULT_INIT="$($VAULT_BINARY init | tee $VAULT_INIT_FILE.tmp)"
				VAULT_INIT=$(cat ${VAULT_INIT_FILE}.tmp)
				mv ${VAULT_INIT_FILE}.tmp $VAULT_INIT_FILE
			fi
			export VAULT_ROOT_TOKEN=$(cat $VAULT_INIT_FILE| grep "Initial Root Token"|awk '{print $4}')
			echo "Root token: $VAULT_ROOT_TOKEN"
			# Get the keys
			KEY1=$(cat $VAULT_INIT_FILE|grep "Unseal Key 1"|awk '{print $4}')
			KEY2=$(cat $VAULT_INIT_FILE|grep "Unseal Key 2"|awk '{print $4}')
			KEY3=$(cat $VAULT_INIT_FILE|grep "Unseal Key 3"|awk '{print $4}')
			echo "KEY1: $KEY1 ; KEY2: $KEY2 ; KEY3: $KEY3"

			# Unseal:
			$VAULT_BINARY unseal $KEY1
			$VAULT_BINARY unseal $KEY2
			$VAULT_BINARY unseal $KEY3

			$VAULT_BINARY status |grep "Mode: active" &>/dev/null
			if [[ $? -eq 0 ]]; then
				echo "Vault unsealed"
				# deply vault nodes
					echo
					echo -e "Deploying the"
					BANNER "Vault nodes"
					echo 

					# Not currently deployed
					# cd $COMPONENTS_DIR/pcs_vault_nodes/

					echo "Backend: $BACKEND"
					set_backend

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
					# Log output into variables
					for i in $(terraform output vault_address | sed "s/,/ /g"); do 
						echo "unsealing: $i"
						export VAULT_ADDR="http://${i}:8200"
						$VAULT_BINARY unseal $KEY1
						$VAULT_BINARY unseal $KEY2
						$VAULT_BINARY unseal $KEY3
					done

					export VAULT_ADDR=${PRIMARY_VAULT_ADDR}

					cd $SCRIPT_DIR
			else
				echo "something went wrong"
			fi
		fi
	else
		echo "VAULT deployment disabled in ${PARAM_FILE} "
	fi	
}