resource "aws_iam_role" "lambda_auth_role" {
  name               = var.lambda_auth_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_apikey_policy" {
  name   = "${var.lambda_auth_name}-apikey-policy"
  policy = data.aws_iam_policy_document.apikey_policy.json
}

resource "aws_iam_role_policy_attachment" "api_key" {
  role       = aws_iam_role.lambda_auth_role.name
  policy_arn = aws_iam_policy.lambda_apikey_policy.arn
}

resource "aws_iam_policy" "auth_logs_access_policy" {
  name   = "${var.lambda_auth_name}-logs-access-policy"
  policy = data.aws_iam_policy_document.auth_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "auth_logs_access_policy_attachment" {
  role       = aws_iam_role.lambda_auth_role.name
  policy_arn = aws_iam_policy.auth_logs_access_policy.arn
}

resource "aws_lambda_function" "auth" {
  function_name = var.lambda_auth_name
  handler       = "lambda_authorizer.lambda_handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_auth_role.arn

  s3_bucket = var.lambda_bucket
  s3_key    = local.lambda_auth_key

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      API_KEY_SSM_PARAM = data.aws_ssm_parameter.api_key_ssm.name
      API_RESOURCE      = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_stage.this.api_id}/${aws_apigatewayv2_stage.this.name}/GET/*"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_auth_group" {
  name              = "/aws/lambda/${aws_lambda_function.auth.function_name}"
  retention_in_days = 1
}

resource "aws_iam_role" "lambda_api_role" {
  name               = var.lambda_api_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "api_logs_access_policy" {
  name   = "${var.lambda_api_name}-logs-access-policy"
  policy = data.aws_iam_policy_document.api_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "api_logs_access_policy_attachment" {
  role       = aws_iam_role.lambda_api_role.name
  policy_arn = aws_iam_policy.api_logs_access_policy.arn
}

resource "aws_lambda_function" "api" {
  function_name = var.lambda_api_name
  handler       = "lambda_handler.handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_api_role.arn

  s3_bucket = var.lambda_bucket
  s3_key    = local.lambda_api_key

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      REPORT_BUCKET = var.jobs_state_bucket
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_api_group" {
  name              = "/aws/lambda/${aws_lambda_function.api.function_name}"
  retention_in_days = 1
}

resource "aws_lambda_permission" "api" {
  statement_id  = "${var.lambda_api_name}-allow-api-gateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "auth" {
  statement_id  = "${var.lambda_auth_name}-allow-api-gateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.lambda_api_name
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${var.lambda_api_name}"
  retention_in_days = 1
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.environment
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit   = 10
    throttling_rate_limit    = 5
    logging_level            = "INFO"
    detailed_metrics_enabled = true
  }

  access_log_settings {
    format = jsonencode({
      requestId       = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      userAgent       = "$context.identity.userAgent"
      requestTime     = "$context.requestTime"
      status          = "$context.status"
      responseLatency = "$context.responseLatency"
    })
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
  }
}

resource "aws_apigatewayv2_authorizer" "this" {
  api_id          = aws_apigatewayv2_api.this.id
  authorizer_type = "REQUEST"
  authorizer_uri  = aws_lambda_function.auth.invoke_arn

  identity_sources = ["$request.header.Authorization"]

  name                              = var.lambda_auth_name
  authorizer_payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api.invoke_arn
  integration_method = "POST"

  request_parameters = {
    # strip the /api from the path
    "overwrite:path" = "/$request.path.proxy"
  }
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.this.id
}
