
### Initialize environment
1. cp ../scripts/setvars-example.sh ../scripts/setvars.sh
2. Update ../scripts/setvars.sh with proper values
3. source ../scripts/setvars.sh
4. Start consul agent
  4.1 consul agent -bootstrap-expect=1 -server -data-dir=$HOME/consul-data -ui -bind=127.0.0.1 -client=0.0.0.0 &
5. sh ../scripts/populate-config.sh
6. terraform init
7. terraform env new $TF_VAR_environment

### Build the splunk AMI
Follow instructions in ./packer/README.md

### Build Splunk Cluster
1. cp ./terraform-example.tfvars ./terraform.tfvars
2. update terraform.tfvars with proper values
3. terraform plan
4. terraform apply


