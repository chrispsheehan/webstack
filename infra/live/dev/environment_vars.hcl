locals {
  global_vars    = read_terragrunt_config(find_in_parent_folders("global_vars.hcl"))
  default_branch = local.global_vars.inputs.default_branch

  # setup temporary branch with env var
  temp_branch = get_env("TEMP_DEPLOY_BRANCH", "")

  # define allowed branches for envirionment
  environment_branches = concat(
    [local.default_branch],
    length(local.temp_branch) > 0 ? [local.temp_branch] : []
  )
}

inputs = {
  environment_branches = local.environment_branches
}