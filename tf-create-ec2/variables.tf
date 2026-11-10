variable "ttt_ami_id" {
  default = "ami-08589c5b85a9fba1a"
}


variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "tech613-nowres-aws-key"
}

variable "instance_name" {
  default = "tech613-nowres-ttt-app-vm"
}

# Database AMI
variable "db_ami_id" {
  default = "ami-067d29b6f16e870bd"
}

# Database server name
variable "db_instance_name" {
  default = "tech613-nowres-db-vm"
}