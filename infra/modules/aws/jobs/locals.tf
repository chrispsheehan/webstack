locals {
  lambda_runtime           = "python3.11"
  lambda_cost_explorer_key = "${var.deploy_version}/${var.cost_explorer_lambda_zip}"
}