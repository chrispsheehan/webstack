locals {
  lambda_runtime   = "python3.11"
  lambda_name      = var.environment == "prod" ? var.project_name : "${var.environment}-${var.project_name}"
  lambda_api_name  = "${local.lambda_name}-api"
  lambda_auth_name = "${local.lambda_name}-auth"
  auth_header_name = "X-Custom-Auth-Header"
  lambda_api_key   = "${var.deploy_version}/${var.api_lambda_zip}"
  lambda_auth_key  = "${var.deploy_version}/${var.auth_lambda_zip}"
}