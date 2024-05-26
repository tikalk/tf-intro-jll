# Creating a terraform module

## **Using Data Sources and Modules**

For more common use cases, such as dynamically fetching the AMI ID, you can use data sources and modules.

1. **Data Source for AMI**: Define a data source to fetch the most recent Ubuntu AMI.

```sh
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

1. **Module for Reusability**: Create a module to encapsulate the creation of an AWS instance. Modules allow you to reuse and share

For this lab's example let's create a `./modules/locate_ami` folder `mkdir -p ./modules/locate_ami` 

We would like to dynamically get the latest amazon_linux ami for the current region we can do that by creating the `./modules/locate_ami/main.tf`
create a `main.tf` with the following content:

```sh
cat<<EOF>>./modules/locate_ami/main.tf
data "aws_ami" "amazone" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}
EOF
```

### terraform init

```sh

Initializing the backend...
Initializing modules...
- ami_locator in ./modules/locate_ami

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

not I run terraform plan -out tfplan

```sh
module.ami_locator.data.aws_ami.ubuntu: Reading...
module.ami_locator.data.aws_ami.amazone: Reading...
module.ami_locator.data.aws_ami.centos: Reading...
module.ami_locator.data.aws_ami.ubuntu: Read complete after 1s [id=ami-0a97c706034fef0b2]
module.ami_locator.data.aws_ami.amazone: Read complete after 1s [id=ami-07ff8415655af0553]
module.ami_locator.data.aws_ami.centos: Read complete after 1s [id=ami-03a077d7c4e72ea87]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.example will be created
  + resource "aws_instance" "example" {
      + ami                                  = "ami-07ff8415655af0553"
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

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
```

## terraform apply

```sh
terraform apply "tfplan"

aws_instance.example: Creating...
aws_instance.example: Still creating... [10s elapsed]
aws_instance.example: Still creating... [20s elapsed]
aws_instance.example: Still creating... [30s elapsed]
aws_instance.example: Creation complete after 33s [id=i-0c41c1542b1605b7d]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Cleaning up with `terraform destroy`

```sh
module.ami_locator.data.aws_ami.centos: Reading...
module.ami_locator.data.aws_ami.ubuntu: Reading...
module.ami_locator.data.aws_ami.amazone: Reading...
module.ami_locator.data.aws_ami.ubuntu: Read complete after 1s [id=ami-0a97c706034fef0b2]
module.ami_locator.data.aws_ami.centos: Read complete after 1s [id=ami-03a077d7c4e72ea87]
module.ami_locator.data.aws_ami.amazone: Read complete after 1s [id=ami-07ff8415655af0553]
aws_instance.example: Refreshing state... [id=i-0c41c1542b1605b7d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.example will be destroyed
  - resource "aws_instance" "example" {
      - ami                                  = "ami-07ff8415655af0553" -> null
      - arn                                  = "arn:aws:ec2:eu-central-1:557680788250:instance/i-0c41c1542b1605b7d" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "eu-central-1a" -> null
      - cpu_core_count                       = 1 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_stop                     = false -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-0c41c1542b1605b7d" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t2.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - monitoring                           = false -> null
      - placement_partition_number           = 0 -> null
      - primary_network_interface_id         = "eni-021fdf1a4f2549917" -> null
      - private_dns                          = "ip-172-31-25-111.eu-central-1.compute.internal" -> null
      - private_ip                           = "172.31.25.111" -> null
      - public_dns                           = "ec2-18-153-206-148.eu-central-1.compute.amazonaws.com" -> null
      - public_ip                            = "18.153.206.148" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [
          - "default",
        ] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-5858d432" -> null
      - tags                                 = {
          - "Name" = "ExampleInstance"
        } -> null
      - tags_all                             = {
          - "Name" = "ExampleInstance"
        } -> null
      - tenancy                              = "default" -> null
      - user_data_replace_on_change          = false -> null
      - vpc_security_group_ids               = [
          - "sg-95ebd3ed",
        ] -> null

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - cpu_options {
          - core_count       = 1 -> null
          - threads_per_core = 1 -> null
        }

      - credit_specification {
          - cpu_credits = "standard" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - maintenance_options {
          - auto_recovery = "default" -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_protocol_ipv6          = "disabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
          - instance_metadata_tags      = "disabled" -> null
        }

      - private_dns_name_options {
          - enable_resource_name_dns_a_record    = false -> null
          - enable_resource_name_dns_aaaa_record = false -> null
          - hostname_type                        = "ip-name" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/xvda" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - tags_all              = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-0aab279d11f418578" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

```

## Beyond this workshop

> there is still a better and easier way to do this ...
> In some cases you can use official registry driven modules