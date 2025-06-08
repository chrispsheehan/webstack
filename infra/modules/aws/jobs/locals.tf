locals {
  lambda_runtime           = "python3.11"
  lambda_cost_explorer_key = "${var.deploy_version}/${var.cost_explorer_lambda_zip}"
  lambda_log_processor_key = "${var.deploy_version}/${var.log_processor_lambda_zip}"
}