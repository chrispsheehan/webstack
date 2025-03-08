locals {
  # global_vars    = read_terragrunt_config("global_vars.hcl")
  # default_branch = local.global_vars.inputs.default_branch

  # environment_branches = [local.default_branch]
  environment_tags = ["*"]
}

inputs = {
  # environment_branches = local.environment_branches
  environment_tags = local.environment_tags
}
