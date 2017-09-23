terraform {
  backend "s3" {
    bucket = "svbrnd-pcs-dev-config"
    key    = "terraform/aws/pcs/vpc/tfstate/terraform.tfstate"
    region = "us-west-2"
    encrypt = "true"
  }
}
