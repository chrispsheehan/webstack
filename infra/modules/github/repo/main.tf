resource "github_repository" "this" {
  name                   = local.repo_name
  delete_branch_on_merge = true

  visibility = local.visibility

  allow_merge_commit = false
  allow_squash_merge = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_protection" "main" {
  repository_id       = github_repository.this.node_id
  pattern             = var.default_branch
  allows_force_pushes = false

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = false
  }
}

resource "github_actions_repository_permissions" "this" {
  repository = github_repository.this.name

  allowed_actions = local.allowed_actions
  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = local.patterns_allowed
  }
}
