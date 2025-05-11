locals {
  variables = {
    AWS_OIDC_ROLE_ARN = "arn:aws:iam::${var.aws_account_id}:role/${var.deploy_role_name}",
    AWS_REGION        = var.aws_region,
    BASE_DOMAIN       = var.root_domain,
    LAMBDA_S3_BUCKET  = var.lambda_bucket,
    WEB_S3_BUCKET     = var.web_bucket
  }
}