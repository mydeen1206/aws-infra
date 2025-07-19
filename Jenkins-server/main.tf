provider "aws" {
  region = "us-east-1" 
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket         = "terraform-bucket-backend-mydeen"
    key            = "dev/vpc/terraform.tfstate"
    region         = "us-east-1"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"              # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "jenkins-server-sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

resource "aws_instance" "jenkins" {
  
  #ami                    = "ami-0150ccaf51ab55a51" 
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  #subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets_id
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[0]  
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "eks-terraform-key"
  associate_public_ip_address = true

  tags = {
    Name = "jenkins-server"
  }
}
