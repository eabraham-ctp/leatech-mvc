#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  ssh-keygen -t rsa -b 4096 -N "" -f $TF_VAR_conn_private_key

cd $SCRIPT_DIR
terraform init
terraform apply
