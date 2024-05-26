Certainly, let's construct a step-by-step tutorial for your workshop focused on Terraform, specifically using the AWS provider. This will guide participants through the process of configuring AWS credentials, writing basic Terraform code for resource deployment, utilizing variables, and leveraging data sources with modules for enhanced modularity and reusability.

### **Introduction to Terraform and AWS Provider**

Terraform by HashiCorp is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

#### **Setting Up AWS Credentials for Terraform**

Before Terraform can interact with AWS, it needs credentials to authenticate with AWS services. This can be achieved in several ways, but one of the most common methods is through the use of the AWS CLI and named profiles.

1. **Install AWS CLI**: Ensure that the AWS CLI is installed on your machine. If it's not, download and install it from the [official AWS CLI website](https://aws.amazon.com/cli/).

2. **Configure AWS CLI**: Run `aws configure` to set up your credentials. This will prompt you for your AWS access key ID, secret access key, AWS region, and output format. Enter your credentials as requested.

   ```shell
   aws configure
   ```

3. **Verify Configuration**: Ensure your configuration is correct by listing your AWS profiles:

   ```shell
   cat ~/.aws/credentials
   ```

4. **Set AWS Profile in Terraform**: In your Terraform configuration, you can specify the profile from your AWS credentials file to use. If you're not using the default profile, specify your profile within the provider block:

   ```hcl
   provider "aws" {
     region  = "us-east-1"
     profile = "your-profile-name"
   }
   ```

#### **Creating a Simple AWS Instance**

Start by creating a basic configuration for deploying an EC2 instance in AWS.

1. **Basic AWS Instance Configuration**: Below is a simple Terraform configuration to create an AWS EC2 instance.

   ```hcl
   provider "aws" {
     region  = "us-east-1"
     profile = "your-profile-name"
   }

   resource "aws_instance" "example" {
     ami           = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
     tags = {
       Name = "ExampleInstance"
     }
   }
   ```

2. **Initialization**: Initialize the Terraform directory to prepare for execution.

   ```shell
   terraform init
   ```

3. **Plan**: Review the actions Terraform will perform.

   ```shell
   terraform plan
   ```

4. **Apply**: Apply the configuration to create the resources.

   ```shell
   terraform apply
   ```

#### **Using Variables**

To enhance flexibility, replace hardcoded values with variables.

1. **Define Variables**: Create a file named `variables.tf` and define variables for the AMI and instance type.

   ```hcl
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

   ```hcl
   resource "aws_instance" "example" {
     ami           = var.ami_id
     instance_type = var.instance_type
     tags = {
       Name = "ExampleInstance"
     }
   }
   ```

3. **Provide Variable Values**: When running `terraform apply`, provide values for the variables either through a `terraform.tfvars` file or via command-line flags.

   ```shell
   terraform apply -var "ami_id=ami-0c55b159cbfafe1f0"
   ```

#### **Using Data Sources and Modules**

For more advanced use cases, such as dynamically fetching the AMI ID, you can use data sources and modules.

1. **Data Source for AMI**: Define a data source to fetch the most recent Ubuntu AMI.

   ```hcl
   data "aws_ami" "ubuntu" {
     most_recent = true
     filter {
       name   = "name"
       values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
     }
     filter {
       name   = "virtualization-type"
       values = ["hvm"]
     }
     owners = ["099720109477"] # Canonical
   }
   ```

2. **Module for Reusability**: Create a module to encapsulate the creation of an AWS instance. Modules allow you to reuse and share