include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  allowed_role_actions = [
    "s3:*",
    "iam:*"
  ]
}

inputs = {
  allowed_role_actions = local.allowed_role_actions
}

terraform {
  source = "tfr:///chrispsheehan/github-oidc-role/aws?version=0.0.4"
}
