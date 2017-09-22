variable "region" {
  description = "The AWS region"
}

variable "org" {
  description = "Organization or Business Unit"
}

variable "environment" {
  description = "SDLC environment"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}
