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

data "aws_iam_policy_document" "cost_explorer_s3_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.jobs_state_bucket}"
    ]
  }
}

data "aws_iam_policy_document" "cost_explorer_logs_policy" {
  statement {
    actions = [
      "s3:PutObject"
    ]

    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.lambda_cost_explorer_group.arn}",
      "${aws_cloudwatch_log_group.lambda_cost_explorer_group.arn}:*"
    ]
  }
}

data "aws_iam_policy_document" "cost_explorer_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ce:GetCostAndUsage"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "state_results_access" {
  statement {
    sid    = "AllowLambdaWriteToCostReports"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        aws_lambda_function.cost_explorer.arn
      ]
    }

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "arn:aws:s3:::${var.jobs_state_bucket}"
    ]
  }
}
