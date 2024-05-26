# Configure the GitHub Provider
# The GitHub provider is used to interact with GitHub organizations. 
# The provider needs to be configured with the proper credentials before it can be used.

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_organization
}