locals {
  lambda_runtime   = "python3.11"
  lambda_name      = var.environment == "prod" ? var.project_name : "${var.environment}-${var.project_name}"
  lambda_auth_name = "${local.lambda_name}-auth"
  lambda_bucket    = "${local.lambda_name}-bucket"
  auth_header_name = "X-Custom-Auth-Header"
}