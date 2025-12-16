terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.3.0"
    }
  }
    backend "s3" {
    bucket         = "terraform-bucket-mydeen-demo"
    key            = "dev/bationhost/terraform.tfstate"
    region         = "us-east-1"
  }
}