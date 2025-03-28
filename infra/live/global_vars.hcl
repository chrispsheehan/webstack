locals {
  aws_region        = "eu-west-2"
  domain_aws_region = "us-east-1"
  default_branch    = "main"
  allowed_role_actions = [
    "s3:*",
    "iam:*",
    "cloudfront:*",
    "wafv2:*",
    "acm:*",
    "route53:*"
  ]
  root_domain = "chrispsheehan.com"
}

inputs = {
  aws_region           = local.aws_region
  default_branch       = local.default_branch
  allowed_role_actions = local.allowed_role_actions
  root_domain          = local.root_domain
}