# Terraform IaC | creating a Github repo

## Introduction to Terraform and GitHub Provider

Terraform is an Infrastructure as Code (IaC) tool that allows you to define and provide data center infrastructure using a declarative configuration language.

This `main.tf` file is a Terraform configuration file. It uses the GitHub provider, which is a plugin for Terraform that allows for the full lifecycle management of GitHub resources.

## Work plan

In this module we would like to do the following:

1. Create a git repository
1. Create 3 groups owners, developers, contributors
1. Add branch protection on branch main and allow pull-requests only with owners approval
1. Allow admin permissions to owners
1. Allow push permissions to developers
1. Allow pull permissions to contributors

## Authenticating with GitHub via `gh-cli`

To authenticate with GitHub via a script, you can use the gh auth login command. However, this command is interactive by default and requires user input, which is not ideal for a script.

To bypass the interactive prompts, you can use the --with-token flag and pipe a Personal Access Token (PAT) into the command. Here's how you can do it:s

```sh
echo $GITHUB_TOKEN | gh auth login --with-token
```

In this script, replace `$GITHUB_TOKEN` with your actual GitHub token. This script will log you into GitHub using the provided token.

Please note that this script should be executed in a secure environment to prevent exposure of your GitHub token. Also, ensure that the token has the necessary permissions for the operations that you intend to perform.

## Creating GitHub Teams

The first part of the `main.tf` file is about creating GitHub teams. A team in GitHub is a group of organization members that reflect your company or group's structure with cascading access permissions and mentions.

```hcl
resource "github_team" "owners" {
  name        = "owners"
  description = "GitHub group for owners"
  privacy     = "closed"
}
```

And we would do the same for developers and contributors 

## Let's get goin!

### Create a project folder

I will use the folder name `github-provider-intro` 

```sh
mkdir ./github-provider-intro && cd ./github-provider-intro
```

### Create our `variables.tf` file

We are going to use three variables for this lab:

1. `github_token` to configure our provider (the same you used with gh cli above)
2. `github_orginzation` - you can create one / use a preexisting one which can be managed by the `github_token` above
3. `repo_name` the name of the repository we wish to create

our `variables.tf` should be created like so (please note to set the variables):

```sh
GITHUB_ORG="your-org-name|tikal-workshops"
REPO_NAME="my_repo_name"
cat<<EOF>>variables.tf
variable "github_token" {
  type = string
}

variable "github_organization" {
  type = string
  default = "${GITHUB_ORG}"
}

variable "repo_name" {
  type = string
  default = "${REPO_NAME}"
}
EOF
```

### Let's create our `provider.tf` file

we are setting the   `token = var.github_token` and `owner = var.github_organization` as we can see in the `provider.tf` below:

```sh
cat<<EOF>provider.tf
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
EOF
```

### We can now start with out `main.tf` file which will create our resource plan

As our plan was above we are creating:

1. 3 groups
2. a repository name my_repo
3. main branch protection
4. assign group permission to the repository

#### We will start with the 3 groups

```sh
# note we are ">" creating the file
cat<<EOF>main.tf
resource "github_team" "owners" {
  name        = "owners"
  description = "GitHub group for owners"
  privacy     = "closed"
}

resource "github_team" "developers" {
  name        = "developers"
  description = "GitHub group for developers"
  privacy     = "closed"
}

resource "github_team" "contributors" {
  name        = "external contributors"
  description = "GitHub group for contributors"
  privacy     = "closed"
}
EOF
```

#### Continue to creating our repo

```sh
# note we are ">>" appending
cat<<EOF>>main.tf

resource "github_repository" "repo" {
  
  name             = var.repo_name
  description      = "My first repository"
  # private          = false
  visibility = "public"
  has_issues       = true
  has_projects     = true
  has_wiki         = true
  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true
}
```

##### Now add branch protection for the `main` branch

```sh
cat<<EOF>>main.tf

resource "github_branch_protection" "repo_protection" {
  repository_id   = github_repository.repo.id
  enforce_admins  = true
  required_pull_request_reviews {
    dismiss_stale_reviews = true
  }
  pattern = "main"
}
```

#### And grant the access level per user group

```sh
cat<<EOF>>main.tf
# admin perms for owners
resource "github_team_repository" "repo_owners" {
  team_id    = github_team.owners.id
  repository = github_repository.repo.name
  permission = "admin"
}

# push perms for developers
resource "github_team_repository" "repo_developers" {
  team_id    = github_team.developers.id
  repository = github_repository.repo.name
  permission = "push"
}
# pull perms for contributors
resource "github_team_repository" "repo_contributors" {
  team_id    = github_team.contributors.id
  repository = github_repository.repo.name
  permission = "pull"
}
EOF
```

### Our `main.tf` should look like the following:

```hcl

resource "github_team" "owners" {
  name        = "owners"
  description = "GitHub group for owners"
  privacy     = "closed"
}

resource "github_team" "developers" {
  name        = "developers"
  description = "GitHub group for developers"
  privacy     = "closed"
}

resource "github_team" "contributors" {
  name        = "external contributors"
  description = "GitHub group for contributors"
  privacy     = "closed"
}



resource "github_repository" "repo" {
  
  name             = var.repo_name
  description      = "My first repository"
  # private          = false
  visibility = "public"
  has_issues       = true
  has_projects     = true
  has_wiki         = true
  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true
}

resource "github_branch_protection" "repo_protection" {
  repository_id   = github_repository.repo.id
  enforce_admins  = true
  required_pull_request_reviews {
    dismiss_stale_reviews = true
  }
  pattern = "main"
}

resource "github_team_repository" "repo_owners" {
  team_id    = github_team.owners.id
  repository = github_repository.repo.name
  permission = "admin"
}

resource "github_team_repository" "repo_developers" {
  team_id    = github_team.developers.id
  repository = github_repository.repo.name
  permission = "push"
}

resource "github_team_repository" "repo_contributors" {
  team_id    = github_team.contributors.id
  repository = github_repository.repo.name
  permission = "pull"
}
```

We are now ready for terraform init, plan and apply !

## Terraform init

Running terraform init should yield

```sh
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of integrations/github from the dependency lock file
- Using previously-installed integrations/github v6.2.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
 hagzag  ~  Projects  training  iac-with-terraform  task excersize-one-plan 

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of integrations/github from the dependency lock file
- Installing integrations/github v6.2.1...
- Installed integrations/github v6.2.1 (signed by a HashiCorp partner, key ID 38027F80D7FD5FB2)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## Terraform plan

Create a plan file by running the following command:

`terraform plan -out tfplan`

which would yield the following plan and plan-file named `tfplan`

```hcl
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # github_branch_protection.repo_protection will be created
  + resource "github_branch_protection" "repo_protection" {
      + allows_deletions                = false
      + allows_force_pushes             = false
      + enforce_admins                  = true
      + id                              = (known after apply)
      + lock_branch                     = false
      + pattern                         = "main"
      + repository_id                   = (known after apply)
      + require_conversation_resolution = false
      + require_signed_commits          = false
      + required_linear_history         = false

      + required_pull_request_reviews {
          + dismiss_stale_reviews           = true
          + require_last_push_approval      = false
          + required_approving_review_count = 1
        }
    }

  # github_repository.repo will be created
  + resource "github_repository" "repo" {
      + allow_auto_merge            = false
      + allow_merge_commit          = true
      + allow_rebase_merge          = true
      + allow_squash_merge          = true
      + archived                    = false
      + default_branch              = (known after apply)
      + delete_branch_on_merge      = false
      + description                 = "My first repository"
      + etag                        = (known after apply)
      + full_name                   = (known after apply)
      + git_clone_url               = (known after apply)
      + has_issues                  = true
      + has_projects                = true
      + has_wiki                    = true
      + html_url                    = (known after apply)
      + http_clone_url              = (known after apply)
      + id                          = (known after apply)
      + merge_commit_message        = "PR_TITLE"
      + merge_commit_title          = "MERGE_MESSAGE"
      + name                        = "my_repo"
      + node_id                     = (known after apply)
      + primary_language            = (known after apply)
      + private                     = (known after apply)
      + repo_id                     = (known after apply)
      + squash_merge_commit_message = "COMMIT_MESSAGES"
      + squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      + ssh_clone_url               = (known after apply)
      + svn_url                     = (known after apply)
      + topics                      = (known after apply)
      + visibility                  = "public"
      + web_commit_signoff_required = false
    }

  # github_team.contributors will be created
  + resource "github_team" "contributors" {
      + create_default_maintainer = false
      + description               = "GitHub group for contributors"
      + etag                      = (known after apply)
      + id                        = (known after apply)
      + members_count             = (known after apply)
      + name                      = "external contributors"
      + node_id                   = (known after apply)
      + parent_team_read_id       = (known after apply)
      + parent_team_read_slug     = (known after apply)
      + privacy                   = "closed"
      + slug                      = (known after apply)
    }

  # github_team.developers will be created
  + resource "github_team" "developers" {
      + create_default_maintainer = false
      + description               = "GitHub group for developers"
      + etag                      = (known after apply)
      + id                        = (known after apply)
      + members_count             = (known after apply)
      + name                      = "developers"
      + node_id                   = (known after apply)
      + parent_team_read_id       = (known after apply)
      + parent_team_read_slug     = (known after apply)
      + privacy                   = "closed"
      + slug                      = (known after apply)
    }

  # github_team.owners will be created
  + resource "github_team" "owners" {
      + create_default_maintainer = false
      + description               = "GitHub group for owners"
      + etag                      = (known after apply)
      + id                        = (known after apply)
      + members_count             = (known after apply)
      + name                      = "owners"
      + node_id                   = (known after apply)
      + parent_team_read_id       = (known after apply)
      + parent_team_read_slug     = (known after apply)
      + privacy                   = "closed"
      + slug                      = (known after apply)
    }

  # github_team_repository.repo_contributors will be created
  + resource "github_team_repository" "repo_contributors" {
      + etag       = (known after apply)
      + id         = (known after apply)
      + permission = "pull"
      + repository = "my_repo"
      + team_id    = (known after apply)
    }

  # github_team_repository.repo_developers will be created
  + resource "github_team_repository" "repo_developers" {
      + etag       = (known after apply)
      + id         = (known after apply)
      + permission = "push"
      + repository = "my_repo"
      + team_id    = (known after apply)
    }

  # github_team_repository.repo_owners will be created
  + resource "github_team_repository" "repo_owners" {
      + etag       = (known after apply)
      + id         = (known after apply)
      + permission = "admin"
      + repository = "my_repo"
      + team_id    = (known after apply)
    }

Plan: 8 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"
```

## Terraform apply

We will now apply our plan by running `terraform apply tfplan`

which would yield: 

```hcl
github_team.owners: Creating...
github_team.developers: Creating...
github_team.contributors: Creating...
github_repository.repo: Creating...
github_team.contributors: Still creating... [10s elapsed]
github_team.developers: Still creating... [10s elapsed]
github_team.owners: Still creating... [10s elapsed]
github_repository.repo: Still creating... [10s elapsed]
github_team.contributors: Creation complete after 18s [id=9860550]
github_team.owners: Creation complete after 18s [id=9860551]
github_team.developers: Creation complete after 18s [id=9860552]
github_repository.repo: Creation complete after 18s [id=my_repo]
github_team_repository.repo_owners: Creating...
github_team_repository.repo_developers: Creating...
github_team_repository.repo_contributors: Creating...
github_branch_protection.repo_protection: Creating...
github_team_repository.repo_owners: Creation complete after 5s [id=9860551:my_repo]
github_team_repository.repo_developers: Creation complete after 6s [id=9860552:my_repo]
github_team_repository.repo_contributors: Creation complete after 6s [id=9860550:my_repo]
github_branch_protection.repo_protection: Creation complete after 9s [id=BPR_kwDOLrJyW84C6cRx]

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
```

## Cleaning up with - Terraform destroy

```sh
github_team.owners: Refreshing state... [id=9860457]
github_team.developers: Refreshing state... [id=9860455]
github_team.contributors: Refreshing state... [id=9860456]
github_repository.repo: Refreshing state... [id=my_repo]
github_team_repository.repo_developers: Refreshing state... [id=9860455:my_repo]
github_team_repository.repo_owners: Refreshing state... [id=9860457:my_repo]
github_team_repository.repo_contributors: Refreshing state... [id=9860456:my_repo]
github_branch_protection.repo_protection: Refreshing state... [id=BPR_kwDOLrI9I84C6bm2]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # github_branch_protection.repo_protection will be destroyed
  - resource "github_branch_protection" "repo_protection" {
      - allows_deletions                = false -> null
      - allows_force_pushes             = false -> null
      - enforce_admins                  = true -> null
      - force_push_bypassers            = [] -> null
      - id                              = "BPR_kwDOLrI9I84C6bm2" -> null
      - lock_branch                     = false -> null
      - pattern                         = "main" -> null
      - repository_id                   = "my_repo" -> null
      - require_conversation_resolution = false -> null
      - require_signed_commits          = false -> null
      - required_linear_history         = false -> null

      - required_pull_request_reviews {
          - dismiss_stale_reviews           = true -> null
          - dismissal_restrictions          = [] -> null
          - pull_request_bypassers          = [] -> null
          - require_code_owner_reviews      = false -> null
          - require_last_push_approval      = false -> null
          - required_approving_review_count = 1 -> null
          - restrict_dismissals             = false -> null
        }
    }

  # github_repository.repo will be destroyed
  - resource "github_repository" "repo" {
      - allow_auto_merge            = false -> null
      - allow_merge_commit          = true -> null
      - allow_rebase_merge          = true -> null
      - allow_squash_merge          = true -> null
      - allow_update_branch         = false -> null
      - archived                    = false -> null
      - default_branch              = "main" -> null
      - delete_branch_on_merge      = false -> null
      - description                 = "My first repository" -> null
      - etag                        = "W/\"729055712e4a83ec4e0e47c118066be9abe0ea44f98dbeab301ff3520410b1bb\"" -> null
      - full_name                   = "tikal-workshops/my_repo" -> null
      - git_clone_url               = "git://github.com/tikal-workshops/my_repo.git" -> null
      - has_discussions             = false -> null
      - has_downloads               = false -> null
      - has_issues                  = true -> null
      - has_projects                = true -> null
      - has_wiki                    = true -> null
      - html_url                    = "https://github.com/tikal-workshops/my_repo" -> null
      - http_clone_url              = "https://github.com/tikal-workshops/my_repo.git" -> null
      - id                          = "my_repo" -> null
      - is_template                 = false -> null
      - merge_commit_message        = "PR_TITLE" -> null
      - merge_commit_title          = "MERGE_MESSAGE" -> null
      - name                        = "my_repo" -> null
      - node_id                     = "R_kgDOLrI9Iw" -> null
      - private                     = false -> null
      - repo_id                     = 783432995 -> null
      - squash_merge_commit_message = "COMMIT_MESSAGES" -> null
      - squash_merge_commit_title   = "COMMIT_OR_PR_TITLE" -> null
      - ssh_clone_url               = "git@github.com:tikal-workshops/my_repo.git" -> null
      - svn_url                     = "https://github.com/tikal-workshops/my_repo" -> null
      - topics                      = [] -> null
      - visibility                  = "public" -> null
      - vulnerability_alerts        = true -> null
      - web_commit_signoff_required = false -> null

      - security_and_analysis {
          - secret_scanning {
              - status = "disabled" -> null
            }
          - secret_scanning_push_protection {
              - status = "disabled" -> null
            }
        }
    }

  # github_team.contributors will be destroyed
  - resource "github_team" "contributors" {
      - create_default_maintainer = false -> null
      - description               = "GitHub group for contributors" -> null
      - etag                      = "W/\"39120266fae29801b02cee39998c8bcc6e69059cf3e43ceb12b43fc56cf9f036\"" -> null
      - id                        = "9860456" -> null
      - members_count             = 0 -> null
      - name                      = "external contributors" -> null
      - node_id                   = "T_kwDOAxsOWs4AlnVo" -> null
      - privacy                   = "closed" -> null
      - slug                      = "external-contributors" -> null
    }

  # github_team.developers will be destroyed
  - resource "github_team" "developers" {
      - create_default_maintainer = false -> null
      - description               = "GitHub group for developers" -> null
      - etag                      = "W/\"2a48045a02e7e896a46ef81f2d3367d7d9f9335c9f01d3516514d7858b15474a\"" -> null
      - id                        = "9860455" -> null
      - members_count             = 0 -> null
      - name                      = "developers" -> null
      - node_id                   = "T_kwDOAxsOWs4AlnVn" -> null
      - privacy                   = "closed" -> null
      - slug                      = "developers" -> null
    }

  # github_team.owners will be destroyed
  - resource "github_team" "owners" {
      - create_default_maintainer = false -> null
      - description               = "GitHub group for owners" -> null
      - etag                      = "W/\"3705abc2e3c76254a3a8e56d9e6a75d7bdbc08ffbb0316d5af8b4e66a20ad2df\"" -> null
      - id                        = "9860457" -> null
      - members_count             = 0 -> null
      - name                      = "owners" -> null
      - node_id                   = "T_kwDOAxsOWs4AlnVp" -> null
      - privacy                   = "closed" -> null
      - slug                      = "owners" -> null
    }

  # github_team_repository.repo_contributors will be destroyed
  - resource "github_team_repository" "repo_contributors" {
      - etag       = "W/\"6a6c1694382945422dfd620799508cccace11b51220a19ff76f0a1ed48e551c9\"" -> null
      - id         = "9860456:my_repo" -> null
      - permission = "pull" -> null
      - repository = "my_repo" -> null
      - team_id    = "9860456" -> null
    }

  # github_team_repository.repo_developers will be destroyed
  - resource "github_team_repository" "repo_developers" {
      - etag       = "W/\"2ea8b336f1cc8b28d0603f7d803f07a2a6db6e68f4e2a783806c7725f042ff62\"" -> null
      - id         = "9860455:my_repo" -> null
      - permission = "push" -> null
      - repository = "my_repo" -> null
      - team_id    = "9860455" -> null
    }

  # github_team_repository.repo_owners will be destroyed
  - resource "github_team_repository" "repo_owners" {
      - etag       = "W/\"9da153cabb4282439eabbcd6a7fd91b0dfa485972c2b264b6552557119b25e8c\"" -> null
      - id         = "9860457:my_repo" -> null
      - permission = "admin" -> null
      - repository = "my_repo" -> null
      - team_id    = "9860457" -> null
    }

Plan: 0 to add, 0 to change, 8 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: 
```

Answering yes would yield:

```sh
github_team_repository.repo_owners: Destroying... [id=9860457:my_repo]
github_team_repository.repo_developers: Destroying... [id=9860455:my_repo]
github_team_repository.repo_contributors: Destroying... [id=9860456:my_repo]
github_branch_protection.repo_protection: Destroying... [id=BPR_kwDOLrI9I84C6bm2]
github_team_repository.repo_contributors: Destruction complete after 0s
github_team.contributors: Destroying... [id=9860456]
github_team_repository.repo_owners: Destruction complete after 1s
github_team.owners: Destroying... [id=9860457]
github_team_repository.repo_developers: Destruction complete after 3s
github_team.developers: Destroying... [id=9860455]
github_branch_protection.repo_protection: Destruction complete after 4s
github_repository.repo: Destroying... [id=my_repo]
github_team.contributors: Destruction complete after 5s
github_team.owners: Destruction complete after 6s
github_team.developers: Destruction complete after 5s
github_repository.repo: Destruction complete after 5s

Destroy complete! Resources: 8 destroyed.
```