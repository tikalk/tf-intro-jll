provider "aws" {
  region = var.region
}

variable "region" {
  type = string
  default = "eu-central-1"
}

variable "ami_id" {
  description = "The AMI id to use for the instance."
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "The instance type of the EC2 instance."
  type        = string
  default     = "t2.micro"
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "ExampleInstance"
  }
}
