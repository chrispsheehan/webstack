locals {
  # setup temporary branch with env var
  temp_branch = get_env("TEMP_DEPLOY_BRANCH", "")

  # define allowed branches for envirionment
  environment_branches = concat(
    ["feature/temp-debug-branch", local.default_branch],
    length(local.temp_branch) > 0 ? [local.temp_branch] : []
  )
}

inputs = {
  environment_branches = local.environment_branches
}
