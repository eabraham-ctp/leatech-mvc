terraform {
  backend "s3" {
    bucket = "svb-rnd-pcs-dev-config"
    key    = "terraform/aws/pcs/vpc/tfstate/terraform.tfstate"
    region = "us-west-2"
    encrypt = "true"
  }
}
