#!/bin/bash
function vpc () {
    if [[ $DEPLOY_VPC == "TRUE" ]]; then
        BANNER "VPC $TF_VAR_vpc_name"
        pause "Press enter key to continue"

        cd $COMPONENTS_DIR/pcs_network/terraform

        echo "Backend: $BACKEND"
        set_backend "aws/pcs/vpc/tfstate"
        
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
        terraform output >> $OUTPUTS_FILE
        # Log output into variables
        export OPENVPN_SERVER_IP=$(terraform output openvpn_address)
        export TF_VAR_vpc_id=$(terraform output vpc_id)
        # Set the service subnets for next modules (consule, vault, chef etc.)
        local subnet_ids=$(for i in $(terraform output service_subnet_ids| tr ',' ' '); do echo -n "\"$i\","; done | sed 's/.$//')
        export TF_VAR_service_subnet_ids=$(echo "[${subnet_ids}]")
        if [[ $DEPLOY_VPC_PEERING == "TRUE" ]]; then
            BANNER "VPC peering"
            pause "Press enter key to continue"

            if [[ -z $VPCPEER_ACCEPTER_ACCT_ID ]] || [[ -z $VPCPEER_ACCEPTER_VPC_CIDR ]] || [[ -z $BACKEND_PROFILE ]]; then
                echo "Please provide the remote VPC details in the parameters file"
                echo "Remote vpc: AWS account ID, vpc CIDR & cli profile name"
            else
                export TF_VAR_vpcpeer_accepter_acct_id=${VPCPEER_ACCEPTER_ACCT_ID}
                export TF_VAR_vpcpeer_accepter_profile=${BACKEND_PROFILE}
                export TF_VAR_vpcpeer_accepter_vpc_cidr=${VPCPEER_ACCEPTER_VPC_CIDR}
                #TECHDEBT - need to find a way to pull this automatically via AWS API
                export TF_VAR_peer_vpc_id=${VPCPEER_ACCEPTER_VPC_ID}
                export TF_VAR_requester_profile=${AWS_PROFILE}

                cd $COMPONENTS_DIR/pcs_vpc_peering/terraform

                echo "Backend: $BACKEND"
                set_backend "aws/pcs/vpcpeer/tfstate"
                
                terraform init
                set_terraform_environment

                echo "Environment: $(terraform env list|grep \*)"

                # terraform plan
                terraform_apply_or_destroy

                # Get requester ID to pass to awscli
                export VPC_REQUESTER_ID=$(terraform output vpc_requester_id)
                export ACCEPTER_STATUS=$(terraform output accepter_accept_status)

                if [ $? -ne 0 ]; then
                  echo
                  echo "ERROR: Could not complete apply, exiting"
                  exit 4
                else
                    case $ACCEPTER_STATUS in
                        active )
                            echo "Peering is connected"
                                # Peering to PCS VPC we need to pass back through VPC peering but want to avoid an eternal loop #TECHDEBT
                                if [ -z $RERUN ] && [ -z $TF_VAR_pcs_vpc_peering_id ]; then
                                    BANNER "Rerun VPC to add routes to other VPCs SET TF_VAR_pcs_vpc_peering_id to stop this happening in future"
                                    export TF_VAR_pcs_vpc_peering_id=$VPC_REQUESTER_ID
                                    export TF_VAR_pcs_vpc_cidr=$VPCPEER_ACCEPTER_VPC_CIDR
                                    export RERUN=true
                                    vpc
                                fi
                            ;;
                        pending-acceptance )
                            echo "Attempting to accept peering requester in ${SERVICES_ACCOUNT}"
                            aws --profile ${SERVICES_ACCOUNT} --region=${REGION}  ec2 accept-vpc-peering-connection --vpc-peering-connection-id ${VPC_REQUESTER_ID} > /dev/null 2>&1 
                            ;;
                        *)
                            echo "Peering state is ${ACCEPTER_STATUS} can not continue"
                            ;;
                    esac

                fi
                echo "-----------------------"
                echo "     stack outputs"
                echo "-----------------------"
                terraform output | tee -a $OUTPUTS_FILE
            fi
        else
            echo "VPC peering is disabled in ${PARAM_FILE}"
        fi
        cd $SCRIPT_DIR
        echo "VPC deployed"
    else
        echo "VPC deployment disabled in ${PARAM_FILE}"
    fi
}