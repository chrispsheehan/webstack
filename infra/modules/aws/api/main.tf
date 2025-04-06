resource "random_string" "api_key" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "api_key_ssm" {
  name        = "/${local.lambda_auth_name}/api_key"
  description = "API key for ${local.lambda_auth_name}"
  type        = "SecureString"
  value       = random_string.api_key.result
}

resource "aws_iam_role" "lambda_auth_role" {
  name               = "${local.lambda_auth_name}-lambda-auth-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_apikey_policy" {
  name   = "${local.lambda_auth_name}-apikey-policy"
  policy = data.aws_iam_policy_document.apikey_policy.json
}

resource "aws_iam_role_policy_attachment" "auth" {
  role       = aws_iam_role.lambda_auth_role.name
  policy_arn = aws_iam_policy.lambda_apikey_policy.arn
}

resource "aws_lambda_function" "auth" {
  function_name = local.lambda_auth_name
  handler       = "lambda_authorizer.lambda_handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_auth_role.arn

  s3_bucket = var.auth_lambda_bucket
  s3_key    = var.auth_lambda_zip

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      API_KEY = aws_ssm_parameter.api_key_ssm.value
      # API_RESOURCE = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_stage.this.api_id}/${aws_apigatewayv2_stage.this.name}/GET/*"
    }
  }
}

resource "aws_iam_role" "lambda_api_role" {
  name               = "${local.lambda_auth_name}-lambda-api-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "auth" {
  function_name = local.lambda_name
  handler       = "lambda_handler.handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_api_role.arn

  s3_bucket = var.lambda_bucket
  s3_key    = var.lambda_zip

  memory_size = 256
  timeout     = 10
}