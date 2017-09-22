variable "region" {
  description = "The AWS region"
}

variable "backend_bucket_name" {
  type = "string"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

