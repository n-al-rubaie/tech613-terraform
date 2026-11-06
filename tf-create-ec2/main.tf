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

# Get current public IP address dynamically
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

# Application Security Group
resource "aws_security_group" "allow_ports" {

  # Security Group name
  name = "tech613-nowres-tf-allow-port-22-3000-80"

  # Allow SSH from my machine only
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Allow application traffic
  ingress {
    description = "Port 3000 access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow web traffic
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

# Database Security Group
resource "aws_security_group" "db_sg" {

  # Database Security Group name
  name = "tech613-nowres-db-sg"

  # Allow MongoDB traffic only from the App Security Group
  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_ports.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech613-nowres-db-sg"
  }
}

# Create App EC2 instance
resource "aws_instance" "my_first_tf_instance" {

  # Custom Tic Tac Toe App AMI
  ami = var.ttt_ami_id

  # EC2 instance size
  instance_type = var.instance_type

  # Existing AWS Key Pair
  key_name = var.key_name

  # Assign a public IP address
  associate_public_ip_address = true

  # Attach App Security Group
  vpc_security_group_ids = [
    aws_security_group.allow_ports.id
  ]

  # Run user data script on first boot
  user_data = templatefile("app-user-data.sh", {
    db_ip = aws_instance.database_vm.private_ip
  })


  tags = {
    Name = var.instance_name
  }
}

# Create Database EC2 instance
resource "aws_instance" "database_vm" {

  # Custom Database AMI
  ami = var.db_ami_id

  # EC2 instance size
  instance_type = var.instance_type

  # Existing AWS Key Pair
  key_name = var.key_name

  # Attach Database Security Group
  vpc_security_group_ids = [
    aws_security_group.db_sg.id
  ]

  tags = {
    Name = var.db_instance_name
  }
}

# Output database private IP address
output "database_private_ip" {
  value = aws_instance.database_vm.private_ip
}