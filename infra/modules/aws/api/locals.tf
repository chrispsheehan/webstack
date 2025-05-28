locals {
  lambda_runtime   = "python3.11"
  auth_header_name = "X-Custom-Auth-Header"
  lambda_api_key   = "${var.deploy_version}/${var.api_lambda_zip}"
  lambda_auth_key  = "${var.deploy_version}/${var.auth_lambda_zip}"
}