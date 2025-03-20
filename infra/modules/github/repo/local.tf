locals {
  repo_name          = split("/", var.github_repo)[1]
  visibility       = var.is_public ? "public" : "private"
  allowed_actions  = var.is_public ? "selected" : "all"
  patterns_allowed = var.is_public ? local.selected_actions : ["*"] # selected actions only allows on public repos

  selected_actions = [
    "dorny/paths-filter@v3",
    "raven-actions/actionlint@v2",
    "extractions/setup-just@v3",
    "autero1/action-terragrunt@v1.3.2"
  ]
}
