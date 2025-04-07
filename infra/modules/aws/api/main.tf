resource "aws_iam_role" "lambda_auth_role" {
  name               = "${local.lambda_auth_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_apikey_policy" {
  name   = "${local.lambda_auth_name}-apikey-policy"
  policy = data.aws_iam_policy_document.apikey_policy.json
}

resource "aws_iam_role_policy_attachment" "api_key" {
  role       = aws_iam_role.lambda_auth_role.name
  policy_arn = aws_iam_policy.lambda_apikey_policy.arn
}

resource "aws_iam_policy" "auth_logs_access_policy" {
  name   = "${local.lambda_auth_name}-logs-access-policy"
  policy = data.aws_iam_policy_document.auth_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "auth_logs_access_policy_attachment" {
  role       = aws_iam_role.lambda_auth_role.name
  policy_arn = aws_iam_policy.auth_logs_access_policy.arn
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
      API_KEY      = data.aws_ssm_parameter.api_key_ssm.value
      API_RESOURCE = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_stage.this.api_id}/${aws_apigatewayv2_stage.this.name}/GET/*"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_auth_group" {
  name              = "/aws/lambda/${aws_lambda_function.auth.function_name}"
  retention_in_days = 1
}

resource "aws_iam_role" "lambda_api_role" {
  name               = "${local.lambda_api_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "api_logs_access_policy" {
  name   = "${local.lambda_api_name}-logs-access-policy"
  policy = data.aws_iam_policy_document.api_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "api_logs_access_policy_attachment" {
  role       = aws_iam_role.lambda_api_role.name
  policy_arn = aws_iam_policy.api_logs_access_policy.arn
}

resource "aws_lambda_function" "api" {
  function_name = local.lambda_api_name
  handler       = "lambda_handler.handler"
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_api_role.arn

  s3_bucket = var.lambda_bucket
  s3_key    = var.lambda_zip

  memory_size = 256
  timeout     = 10
}

resource "aws_cloudwatch_log_group" "lambda_api_group" {
  name              = "/aws/lambda/${aws_lambda_function.api.function_name}"
  retention_in_days = 1
}

resource "aws_lambda_permission" "api" {
  statement_id  = "${local.lambda_api_name}-allow-api-gateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "auth" {
  statement_id  = "${local.lambda_auth_name}-allow-api-gateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_acm_certificate" "api_cert" {
  domain_name       = var.api_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.this.id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "api" {
  depends_on              = [aws_acm_certificate.api_cert]
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
}

resource "aws_apigatewayv2_domain_name" "this" {
  depends_on = [aws_acm_certificate_validation.api]

  domain_name = var.api_domain
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this.id
  name    = aws_apigatewayv2_domain_name.this.domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api" "this" {
  name          = local.lambda_api_name
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${local.lambda_api_name}"
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

resource "aws_apigatewayv2_api_mapping" "this" {
  api_id          = aws_apigatewayv2_api.this.id
  domain_name     = aws_apigatewayv2_domain_name.this.id
  stage           = aws_apigatewayv2_stage.this.id
  api_mapping_key = ""
}

resource "aws_apigatewayv2_authorizer" "this" {
  api_id          = aws_apigatewayv2_api.this.id
  authorizer_type = "REQUEST"
  authorizer_uri  = aws_lambda_function.auth.invoke_arn

  identity_sources = ["$request.header.Authorization"]

  name                              = local.lambda_auth_name
  authorizer_payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api.invoke_arn
  integration_method = "POST"

  request_parameters = {
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

# resource "aws_apigatewayv2_route" "this" {
#   api_id    = aws_apigatewayv2_api.this.id
#   route_key = "ANY /{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.this.id}"

#   authorization_type = "CUSTOM"
#   authorizer_id      = aws_apigatewayv2_authorizer.this.id
# }

# resource "aws_apigatewayv2_integration" "example" {
#   api_id             = aws_apigatewayv2_api.this.id
#   integration_type   = "HTTP_PROXY"
#   integration_method = "ANY"
#   integration_uri    = "https://${var.api_domain}"
#   request_parameters = {
#     "overwrite:path" = "/$request.path.proxy"
#   }
# }

# resource "aws_apigatewayv2_route" "example" {
#   api_id    = aws_apigatewayv2_api.this.id
#   route_key = "ANY /api/{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.example.id}"
# }
# resource "aws_apigatewayv2_route" "default_route" {
#   api_id    = aws_apigatewayv2_api.this.id
#   route_key = "$default"
#   target    = "integrations/${aws_apigatewayv2_integration.this.id}"

#   authorization_type = "CUSTOM"
#   authorizer_id      = aws_apigatewayv2_authorizer.this.id
# }