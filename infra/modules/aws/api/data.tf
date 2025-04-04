data "aws_caller_identity" "current" {}

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
    actions   = [
      "ssm:GetParameter"
    ]
    resources = [
      aws_ssm_parameter.api_key_ssm.arn
    ]
  }
}
