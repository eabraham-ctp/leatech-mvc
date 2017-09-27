#!/bin/bash

function terraform_apply_squid () {
	if [[ $DEPLOY_SQUID == "TRUE" ]]; then

		BANNER "Squid Cluster"
		pause "Press enter key to continue"

        if [ $DEPLOY_ROUTE53 == "TRUE" ]; then
            cd $COMPONENTS_DIR/pcs_route53/terraform
            export TF_VAR_private_domain=$(terraform output private_domain)
            export TF_VAR_route53_zone_id=$(terraform output zone_id)
        fi

	    # Verify that the service subnets are set - this will require some work around #TECHDEBT there are nicer ways to do this
		if [ -z ${TF_VAR_dmz_subnet_ids} ]  && [ $ACTION != "Destroying" ]; then
			cd $COMPONENTS_DIR/pcs_network/terraform
			local subnet_ids=$(for i in $(terraform output dmz_subnets_ids| tr ',' ' '); do echo -n "\"$i\","; done | sed 's/.$//')
			export TF_VAR_dmz_subnet_ids=$(echo "[${subnet_ids}]")
			export TF_VAR_vpc_id=$(terraform output vpc_id)
			export TF_VAR_common_sg=$(terraform output common_sg)
			export TF_VAR_ssh_sg=$(terraform output ssh_sg)

		fi
		cd $COMPONENTS_DIR/pcs_squid/terraform

		echo "Backend: $BACKEND"
		set_backend "aws/pcs/squid/tfstate"

		terraform init
		set_terraform_environment
		
		echo "Environment: $(terraform env list|grep \*)"
		pause "Press enter key to continue"

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
		terraform output >> $OUTPUTS_FILE
		# Log output into variables
		export TF_VAR_squid_elb_address=$(terraform output squid_elb_address)
		export TF_VAR_squid_elb_sg=$(terraform output squid_elb_sg)	
		cd $SCRIPT_DIR
	else
		echo "SQUID deployment disabled in ${PARAM_FILE}"
	fi	
}