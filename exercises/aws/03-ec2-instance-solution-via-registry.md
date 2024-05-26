# Working with terraform registry

## Perquisites

- access to an aws account ;)
- `aws-cli`
- `jq`

## Where do we want to go today ?

Creating an `ec2-instance`

### other requirements ?

1. Disk size ? 
   in our case an additional ebs volume size or the `root-fs` volume size ?
1. Specify the ssh-key we wish to use to connect ...

### How could we connect with no `security-group` ?

1. A `securty-group` ...

## There are official modules for all the above!

- [terraform-aws-key-pair](https://github.com/terraform-aws-modules/terraform-aws-key-pair)
- [terraform-aws-security-group](https://github.com/terraform-aws-modules/terraform-aws-security-group)
- [terraform-aws-ec2-instance](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/)

### get ssh-private key from our local `terraform.tfstate` 

> this is why this method is not secure and should be used just in rare cases like this / for demo purposes ...

```sh
jq -r '.resources[] | select(.type == "tls_private_key" and .name =
= "this") | .instances[].attributes.private_key_openssh' terraform.tfstate > ~/.ssh/key-via-terraform.pem
```

- We will store the file in `~/.ssh` directory, we Must! ensure file security by running

```sh
chmod 0400 ~/.ssh/key-via-terraform.pem
```

### Get the public ip address from the `terraform.tfstate` like so:

```sh
jq -r '.resources[] | select(.type == "aws_instance" and .name == "this") | .instances[].attributes.public_ip' terraform.tfstate
```

### Let's connect

The ip address will obviously be different in each use case 

```sh
ssh -i ~/.ssh/key-via-terraform.pem XX.YY.ZZ.AAA -l ec2-user
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2025-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/

[ec2-user@ip-172-31-41-212 ~]$ dig +short myip.opendns.com @resolver1.opendns.com
```


```sh
dig +short myip.opendns.com @resolver1.opendns.com
```

## terraform show

```sh
chmod 0644 ~/.ssh/key-via-terraform.pem
```

### terraform init

```sh

```

### terraform plan

```sh

```

### terraform apply

```sh

```

## Cleaning up with `terraform destroy`

```sh

```
