function pause (){
	if [[ $DISABLE_PAUSE != "true" ]]; then
	   if [[ "$*" == "" ]]; then
	    	read -p "Press any Enter to continue..."
	    else
		    	read -p "$*"
	    fi 
	fi
}

function check_dependencies () {
	echo "Checking Dependencies"
	# Check if Terraform installed
	which terraform > /dev/null
	if [ $? -ne 0 ]; then
		echo ""
		echo "  terraform is needed for this script but it is not installed, please install it first."
		echo "  "
		exit
	else
		export TERRAFORM_BINARY=$(which terraform)
	fi

	# Check if JQ installed
	which jq > /dev/null
	if [ $? -ne 0 ]; then
		echo ""
		echo "  jq is needed for this script but it is not installed, please install it first."
		echo "  Please refer to - https://stedolan.github.io/jq/download/"
		exit
	else
		export JQ_BINARY=$(which jq)
	fi

	# # Check if OpenVPN installed
	# which openvpn > /dev/null
	# if [ $? -ne 0 ]; then
	# 	echo ""
	# 	echo "  Openvpn is needed for the deployment from outside the VPC, please install it first"
	# 	echo "  Please refer to - https://openvpn.net/index.php/access-server/docs/admin-guides/182-how-to-connect-to-access-server-with-linux-clients.html"
	# else
	# 	export OPENVPN_BINARY=$(which openvpn)
	# 	# echo "OPENVPN_BINARY: $OPENVPN_BINARY"
	# fi

	# Check if vault installed
	which vault > /dev/null
	if [ $? -ne 0 ]; then
		echo ""
		echo "  Vault is needed for the deployment, please install it first"
		exit
	else
		export VAULT_BINARY=$(which vault)
	fi

	# Check if figlet installed
	which figlet > /dev/null
	if [ $? -ne 0 ]; then
	BANNER () {
		echo '#########################'
		echo  $1
		echo '#########################'

	}
	else
	BANNER () {
		figlet $1
	}
	fi
}

function set_terraform_environment () {
	terraform env list|grep "$TERRAFORM_ENV" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
	  terraform env select $TERRAFORM_ENV
	else
	  terraform env new $TERRAFORM_ENV
	fi
	echo "Environment set to: ${TERRAFORM_ENV}"
}

function terraform_apply_or_destroy () {
	if [[ $ACTION == "Destroying" ]]; then
		echo Destroy
		terraform destroy
	else
		if [ -z $APPLYMODE ]; then
			APPLYMODE=apply
		fi
			terraform $APPLYMODE

	fi
}

function set_backend () {
	local STATE_PATH=$1
	if [[ $BACKEND == "s3" ]]; then
		cat << EOF > ./backend.tf.tmp
terraform {
  backend "s3" {
    bucket = "${TF_VAR_backend_bucket_name}"
    key    = "terraform/$STATE_PATH/terraform.tfstate"
    region = "${TF_VAR_region}"
    encrypt = "true"
  }
}
EOF
		if [[ -f "./backend.tf" ]]; then
			diff ./backend.tf.tmp ./backend.tf > /dev/null
			if [[ $? -ne 0 ]]; then
				mv backend.tf backend.tf.$(date +%s).back
			fi
		fi
	mv ./backend.tf.tmp ./backend.tf
	fi

	if [[ "$BACKEND" == "consul" ]]; then
		echo -e "\n####################################################\n"
		echo -e " Using Consul"
		echo -e " * Consul Master IP from AWS: $CONSUL_MASTER_IP"
		echo -e " * CONSUL http address:       $CONSUL_HTTP_ADDR"
		echo -e ""
		echo -e " setting backend path to $STATE_PATH"
		echo -e "\n####################################################\n"
		pause "Press any key to continue"

		cat << EOF > ./backend.tf.tmp
terraform {
 backend "consul" {
   path = "$STATE_PATH"
 }
}
EOF
		if [[ -f "./backend.tf" ]]; then
			diff ./backend.tf.tmp ./backend.tf > /dev/null
			if [[ $? -ne 0 ]]; then
				mv backend.tf backend.tf.$(date +%s).back
			fi
		fi
		mv ./backend.tf.tmp ./backend.tf	
	fi

	if [[ $BACKEND == "local" ]]; then
		echo "Using local backend"
		if [[ -f "./backend.tf" ]]; then
			mv backend.tf backend.tf.off
		fi
	# else
	# 	echo "Using consul backend"
	# 	if [[ -f "./backend.tf.off" ]]; then
	# 		mv backend.tf.off backend.tf
	# 		# assuming openvpn config is already set
	# 	fi
	fi
}

# Multi-use function to upload a node/role/environment to the Chef Server
function chef_load (){
	if ! knife $1 from file $2; then
		echo "$1 failed to load"
		exit 31
	fi
}
