# Specify the providers Terraform will use
terraform {
  required_providers {

    # AWS provider for creating AWS resources
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    # HTTP provider used to retrieve my current public IP address dynamically
    http = {
      source = "hashicorp/http"
    }
  }
}

# Create infrastructure in AWS Ireland region
provider "aws" {

  # AWS Region (Ireland)
  region = "eu-west-1"
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

# Security Group created by Terraform
resource "aws_security_group" "allow_ports" {

  # Security Group name required by the task
  name = "tech613-nowres-tf-allow-port-22-3000-80"

  # Allow SSH from my machine only
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Allow application access from anywhere
  ingress {
    description = "Port 3000 access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow web traffic from anywhere
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech613-nowres-tf-allow-port-22-3000-80"
  }
}

# Create an EC2 instance
resource "aws_instance" "my_first_tf_instance" {

  # Ubuntu 22.04 AMI
  ami = var.test_ami_id

  # Instance size
  instance_type = var.instance_type

  # Existing AWS Key Pair
  key_name = var.key_name

  # Assign a public IP address
  associate_public_ip_address = true

  # Attach Security Group created above
  vpc_security_group_ids = [
    aws_security_group.allow_ports.id
  ]

  # Instance Name tag
  tags = {
    Name = var.instance_name
  }
}