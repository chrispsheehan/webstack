output "lambda_cost_explorer_name" {
  value = aws_lambda_function.cost_explorer.function_name
}

output "lambda_log_processor_name" {
  value = aws_lambda_function.log_processor.function_name
}
