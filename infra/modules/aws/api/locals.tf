locals {
  lambda_runtime   = "nodejs18.x"
  lambda_name      = var.environment == "prod" ? var.project_name : "${var.environment}-${var.project_name}"
  lambda_bucket    = "${local.lambda_name}-bucket"
  auth_header_name = "X-Custom-Auth-Header"
}