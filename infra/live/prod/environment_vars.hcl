locals {
  global_vars          = read_terragrunt_config(find_in_parent_folders("global_vars.hcl"))
  default_branch       = local.global_vars.inputs.default_branch
  environment_tags     = ["*"]
  environment_branches = [local.default_branch]
  log_retention_days   = 14
}

inputs = {
  environment_tags     = local.environment_tags
  environment_branches = local.environment_branches
  log_retention_days   = local.log_retention_days
}
