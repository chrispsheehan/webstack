resource "random_string" "api_key" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "api_key_ssm" {
  name        = var.api_key_ssm
  description = "API key for ${var.project_name}"
  type        = "SecureString"
  value       = random_string.api_key.result
}
