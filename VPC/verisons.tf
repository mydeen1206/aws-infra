terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.3.0"
    }
  }
    backend "s3" {
    bucket         = "terraform-bucket-backend-mydeen"
    key            = "dev/vpc/terraform.tfstate"
    region         = "us-east-1"
  }
}
 