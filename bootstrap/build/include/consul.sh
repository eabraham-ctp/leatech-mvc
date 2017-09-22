#!/bin/bash

function terraform_apply_consul () {
	if [[ $DEPLOY_CONSUL == "TRUE" ]]; then
		BANNER "Consul"
		pause "Press enter key to continue"

	    # Verify that the service subnets are set - this will require some work around #TECHDEBT there are nicer ways to do this
		if [[ -z ${TF_VAR_service_subnet_ids} ]]; then
			cd $COMPONENTS_DIR/pcs_network/terraform
			local subnet_ids=$(for i in $(terraform output service_subnet_ids| tr ',' ' '); do echo -n "\"$i\","; done | sed 's/.$//')
			export TF_VAR_service_subnet_ids=$(echo "[${subnet_ids}]")
	
		fi

		export TF_VAR_vpc_id=$(terraform output vpc_id)
		export TF_VAR_openvpn_sg=$(terraform output openvpn_sg)
		export TF_VAR_common_sg=$(terraform output common_sg)
		export TF_VAR_sec_service_sg=$(terraform output sec_service_sg)
		export TF_VAR_ssh_sg=$(terraform output ssh_sg)		
		
		# Verify squid proxy is set #TECH optional?
		if [[ -z ${TF_VAR_squid_elb_address} ]]; then
			cd $COMPONENTS_DIR/pcs_squid/terraform
			export TF_VAR_squid_elb_address=$(terraform output squid_elb_address)
			export TF_VAR_squid_elb_sg=$(terraform output squid_elb_sg)	
		fi
		
		cd $COMPONENTS_DIR/pcs_consul/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/consul/tfstate"

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
		export CONSUL_HTTP_ADDR=$(terraform output consul_address):8500
		if [ $? -gt 0 ]; then
			pause "Consul failed to build correctly will exit, clean EC2 instances manually to prevent backend confusion"
			exit 13
		fi
        

		BANNER "Creating Config keys in Consul"
		cd $COMPONENTS_DIR/pcs_consul_dataload/terraform

		terraform init
		set_terraform_environment
		terraform_apply_or_destroy

		# Make sure all the TFstates exist in Consul
        push_tfstate_to_consul

		cd $SCRIPT_DIR

	else
		echo "CONSUL deployment disabled in ${PARAM_FILE}."
	fi	

	# If we're using a shared Consul, Consul will be disable in the Parms file so check for a Consul profile
	if [ ! -z $CONSUL_PROFILE ]; then
		BANNER "Creating Config keys in Consul"
		cd $COMPONENTS_DIR/pcs_consul_dataload/terraform

		terraform init
		set_terraform_environment
		terraform_apply_or_destroy		

		# Make sure all the TFstates exist in Consul
	    push_tfstate_to_consul
	fi
	
	cd $SCRIPT_DIR
}
