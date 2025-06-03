data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name = var.root_domain
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "apikey_policy" {
  statement {
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      data.aws_ssm_parameter.api_key_ssm.arn
    ]
  }
}

data "aws_iam_policy_document" "api_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.lambda_api_group.arn}",
      "${aws_cloudwatch_log_group.lambda_api_group.arn}:*"
    ]
  }
}

data "aws_iam_policy_document" "auth_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.lambda_auth_group.arn}",
      "${aws_cloudwatch_log_group.lambda_auth_group.arn}:*"
    ]
  }
}