locals {
  aws_region     = "eu-west-2"
  default_branch = "main"
  allowed_role_actions = [
    "s3:*",
    "iam:*"
  ]
}

inputs = {
  aws_region          = local.aws_region
  default_branch      = local.default_branch
  allowed_role_actions = local.allowed_role_actions
}