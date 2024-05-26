# Terraform IaC | creating an ec2 instance

## Introduction to Terraform AWS Provider

Terraform by HashiCorp is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

### Setting Up AWS Credentials for Terraform

Before Terraform can interact with AWS, it needs credentials to authenticate with AWS services. This can be achieved in several ways, but one of the most common methods is through the use of the AWS CLI and named profiles.

**Install AWS CLI:** Ensure that the AWS CLI is installed on your machine. If it's not, download and install it from the official AWS CLI website.

**Configure AWS CLI:** Run `aws configure` to set up your credentials. This will prompt you for your AWS access key ID, secret access key, AWS region, and output format. Enter your credentials as requested.

if you now examine the aws credentials file, `cat ~/.aws/credentials` you should see your credentials. 

If your company uses SSO `aws` / `okta` other - you should be the expert on how to execute that specific command - please call out for help if needed.

## Infra As Code - creating an ec2 instance

### Setup provider

Like with every terraform provider comes the authentication against it's api in our case `aws` and considering we just authenticated we do not need any more than region (or the default region will be used - us-east-1).

```sh
provider "aws" {
  region  = "eu-central-1"
}
```

### Create `aws_instance` resource

**Basic AWS Instance Configuration:** Below is a simple Terraform configuration to create an AWS EC2 instance.

[resource reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) this resource has many options ...

A basic example would be:

```sh

provider "aws" {
  region  = "eu-central-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = "ExampleInstance"
  }
}
```

## D.R.Y Principles

### **Using Variables**

To enhance flexibility, replace hardcoded values with variables.

1. **Define Variables**: Create a file named `variables.tf` and define variables for the AMI and instance type.

```sh

variable "ami_id" {
  description = "The AMI id to use for the instance."
  type        = string
}

variable "instance_type" {
  description = "The instance type of the EC2 instance."
  type        = string
  default     = "t2.micro"
}

```

2. **Update Instance Resource**: Modify your `aws_instance` resource to use these variables.

```sh
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "ExampleInstance"
  }
}
```

### terraform init

```sh
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.44.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### terraform plan

```sh
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.example will be created
  + resource "aws_instance" "example" {
      + ami                                  = "ami-0c55b159cbfafe1f0"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "ExampleInstance"
        }
      + tags_all                             = {
          + "Name" = "ExampleInstance"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
╷
│ Warning: Value for undeclared variable
│ 
│ The root module does not declare a variable named "region" but a value was found in file "terraform.tfvars". If you
│ meant to use this value, add a "variable" block to the configuration.
│ 
│ To silence these warnings, use TF_VAR_... environment variables to provide certain "global" settings to all
│ configurations in your organization. To reduce the verbosity of these warnings, use the -compact-warnings option.
╵

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
```

### terraform apply - expecting to fail !

```sh
 tfa
aws_instance.example: Creating...
╷
│ Error: creating EC2 Instance: InvalidAMIID.NotFound: The image id '[ami-0c55b159cbfafe1f0]' does not exist
│       status code: 400, request id: 47654064-0616-4f3e-952b-d024f10769cd
│ 
│   with aws_instance.example,
│   on main.tf line 22, in resource "aws_instance" "example":
│   22: resource "aws_instance" "example" {
```

## Let's do it better in lab [**02**](02-ec2-ami-module.md)