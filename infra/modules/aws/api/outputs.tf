output "api_invoke_domain" {
  value = replace(
    replace(aws_apigatewayv2_stage.this.invoke_url, "https://", ""),
    "/${aws_apigatewayv2_stage.this.name}",
    ""
  )
}
