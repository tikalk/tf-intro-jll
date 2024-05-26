provider "aws" {
  region = var.region
}

variable "region" {
  type = string
  default = "eu-central-1"
}

variable "instance_type" {
  description = "The instance type of the EC2 instance."
  type        = string
  default     = "t2.micro"
}

module "ami_locator" {
  source = "./modules/locate_ami"
}

resource "aws_instance" "example" {
  ami           = module.ami_locator.regional_amazone_ami_id # Use an appropriate AMI for your region
  instance_type = "t2.micro" # Choose the instance type

  tags = {
    Name = "ExampleInstance"
  }
}