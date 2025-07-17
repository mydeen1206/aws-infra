# Define Local Values in Terraform
locals {
  #owners = mydeen
  environment = var.environment
  name = "${var.environment}"
  common_tags = {
    environment = local.environment
  }
} 