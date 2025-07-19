# Define Local Values in Terraform
locals {
  environment = var.environment
  name = "${var.environment}"
  common_tags = {
    environment = local.environment
  }
  eks_cluster_name = "${data.terraform_remote_state.eks.outputs.cluster_id}"  
} 