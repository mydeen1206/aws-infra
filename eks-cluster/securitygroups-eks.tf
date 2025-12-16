#DATA SOURCE
# This data source retrieves the VPC ID and public subnets from the remote state of the VPC module.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket         = "terraform-bucket-mydeen-demo"
    key            = "dev/vpc/terraform.tfstate"
    region         = "us-east-1"
  }
}
# Security Group for EKS Node Group - Placeholder file
resource "aws_security_group" "bastion_sg" {
  name        = "nodegroup-sg"
  description = "Allow SSH access"
  #vpc_id      = "vpc-02a448c0f68eaf718"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nodegroup-sg"
  }
}