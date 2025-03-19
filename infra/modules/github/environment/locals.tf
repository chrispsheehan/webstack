locals {
  variables = {
    AWS_OIDC_ROLE_ARN = "arn:aws:iam::${var.aws_account_id}:role/${var.deploy_role_name}",
    AWS_REGION        = var.aws_region
  }
}