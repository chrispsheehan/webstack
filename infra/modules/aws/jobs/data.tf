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

data "aws_iam_policy_document" "cost_explorer_iam_policy" {
  statement {
    sid = "AllowLambdaCloudwatchLogGroupPut"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.lambda_cost_explorer_group.arn}",
      "${aws_cloudwatch_log_group.lambda_cost_explorer_group.arn}:*"
    ]
  }

  statement {
    sid = "AllowLambdaCostExplorerGet"

    effect = "Allow"

    actions = [
      "ce:GetCostAndUsage"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowLambdaCostExplorerS3Put"

    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "arn:aws:s3:::${var.jobs_state_bucket}/*"
    ]
  }
}
