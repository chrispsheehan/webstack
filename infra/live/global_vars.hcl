locals {
  aws_region        = "eu-west-2"
  domain_aws_region = "us-east-1"
  default_branch    = "main"
  deploy_environments = [
    "dev",
    "prod"
  ]
  allowed_role_actions = [
    "s3:*",
    "iam:*",
    "cloudfront:*",
    "wafv2:*",
    "acm:*",
    "route53:*",
    "lambda:*",
    "ssm:*",
    "logs:*",
    "apigateway:*"
  ]
  root_domain = "chrispsheehan.com"
}

inputs = {
  aws_region           = local.aws_region
  default_branch       = local.default_branch
  allowed_role_actions = local.allowed_role_actions
  deploy_environments  = local.deploy_environments
  root_domain          = local.root_domain
}