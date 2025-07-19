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
}
