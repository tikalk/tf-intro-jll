# Terraform training

## Getting started with Terraform

These labs were desinged in order to get aquanited with terraform

## Perquisites

- Terraform `>=v1.5.7`
- An IDE e.g [vscodium](https://vscodium.com/)
- Access to an **`aws`** [/`gcp`/`azure`] account
- Github and a [Personal Address Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#keeping-your-personal-access-tokens-secure)

## Labs by provider

Terraform providers are the interface terraform uses in order to control the provider's api endpoint, in general each provider has it nuances.
![img](https://i.imgur.com/bjY5xhf.png)

### Github provider  Labs

- [Create a Github repository with terraform + GitHub provider](exercises/github-provider-intro.md)

### AWS provider  Labs

- [Validate you AWS account setup - using terraform](https://github.com/tikalk/tf-intro-jll/blob/main/exercises/aws/00-account-validator.md)
- [Create ec2 instance via terraform resources](https://github.com/tikalk/tf-intro-jll/blob/main/exercises/aws/01-ec2-instance.md)
- [Create ec2 instance via utility module](https://github.com/tikalk/tf-intro-jll/blob/main/exercises/aws/02-ec2-ami-module.md)
- [Create ec2 instance via terraform registry modules](https://github.com/tikalk/tf-intro-jll/blob/main/exercises/aws/03-ec2-instance-solution-via-registry.md)

### Gitlab provider Labs
