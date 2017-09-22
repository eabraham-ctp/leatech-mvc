# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul Dataload - bootstrap
#
# Loads the configuraiton paramters in to Consul
#

### BEGIN backend state storage
### Rename this file to backend.tf for initial bootstrap. After Consul is available,
### Rename this file back to backend.tf perform 'terraform init' to copy the state to Consul.

terraform {
  backend "consul" {
    path = "aws/pcs/consul_dataload/tfstate"
  }
}
### END backend state storage
