
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    aws = {
      source = "hashicorp/aws"
      version = "6.3.0"
    }
  }
    backend "s3" {
    bucket         = "terraform-bucket-backend-mydeen"
    key            = "dev/eks-irsa-demo/terraform.tfstate"
    region         = "us-east-1"
  }
}


data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket         = "terraform-bucket-backend-mydeen"
    key            = "dev/eks/terraform.tfstate"
    region         = "us-east-1"
  }
}

# Terraform AWS Provider Block

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host = data.terraform_remote_state.eks.outputs.cluster_endpoint 
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token
}

