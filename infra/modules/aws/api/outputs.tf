output "api_url" {
  value = aws_apigatewayv2_stage.this.invoke_url
}

output "api_key_ssm_name" {
  value = aws_ssm_parameter.api_key_ssm.name
}
