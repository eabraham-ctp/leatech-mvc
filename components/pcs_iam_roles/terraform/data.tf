
data "terraform_remote_state" "kms" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/kms/tfstate"
  }
}
