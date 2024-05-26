# tf-validate

> a helper module

Provides a way to quickly check the provider config:

Example usage:

```sh
git clone <this repo>

$ tfi

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Installing hashicorp/aws v3.73.0...
- Installed hashicorp/aws v3.73.0 (signed by HashiCorp)

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

bash-5.1$> tfp && tfa

Changes to Outputs:
  + account_caller_id = "557XXX788XXX"
  + account_id        = "557XXX788XXX"
  + caller_arn        = "arn:aws:iam::557XXX788XXX:user/hagzag@tikalk.com"
  + caller_user       = "AIDAYDWC5QMNAPNZBBBJS"

You can apply this plan to save these new output values to the Terraform state, without changing any real
infrastructure.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

account_caller_id = "557XXX788XXX"
account_id = "557XXX788XXX"
caller_arn = "arn:aws:iam::557XXX788XXX:user/hagzag@tikalk.com"
caller_user = "AIDAYDWC5QMNAPNZBBBJS"
```