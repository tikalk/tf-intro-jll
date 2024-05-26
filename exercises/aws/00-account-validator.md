# Terraform IaC | tf-validator

## Validating you have access to an aws account

As with every terraform workflow:

1. `terraform init -chdir modules/aws/tf-validator`
2. `terraform -chdir=./modules/aws/tf-validator plan`
3. `terraform -chdir=./modules/aws/tf-validator apply`

Would yield:`

```sh
terraform -chdir=./modules/tf-validator init

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

terraform -chdir=./modules/tf-validator plan
data.aws_caller_identity.current: Reading...
data.aws_caller_identity.current: Read complete after 0s [id=557680788250]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
 hagzag  ~  Projects  training  iac-with-terraform  terraform -chdir=./modules/tf-validator apply
data.aws_caller_identity.current: Reading...
data.aws_caller_identity.current: Read complete after 0s [id=557680788250]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

account_caller_id = "557680788250"
account_id = "557680788250"
caller_arn = "arn:aws:sts::557680788250:assumed-role/AWSReservedSSO_Administrator
caller_user = "AROAYDWC5QMNJHWLGRBUS:hagzag@tikalk.com"
```