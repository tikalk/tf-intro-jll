
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