resource "github_repository_environment" "this" {
  environment         = var.environment
  repository          = data.github_repository.this.name
  prevent_self_review = true

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "branch" {
  for_each = toset(var.environment_branches)

  repository     = data.github_repository.this.name
  environment    = github_repository_environment.this.environment
  branch_pattern = each.value
}

resource "github_repository_environment_deployment_policy" "tag" {
  for_each = toset(var.environment_tags)

  repository  = data.github_repository.this.name
  environment = github_repository_environment.this.environment
  tag_pattern = each.value
}

resource "github_actions_environment_variable" "this" {
  for_each = local.variables

  repository    = data.github_repository.this.name
  environment   = github_repository_environment.this.environment
  variable_name = each.key
  value         = each.value
}
