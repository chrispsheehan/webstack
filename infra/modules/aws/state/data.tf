data "aws_iam_policy_document" "s3_state_access_policy" {
  statement {
    sid = "AllowCostExplorerLambdaPutStateS3Object"

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:role/${var.lambda_cost_explorer_name}"
      ]
    }

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "arn:aws:s3:::${var.jobs_state_bucket}/*"
    ]
  }

  statement {
    sid = "AllowAPILambdaGetStateS3Object"

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:role/${var.lambda_api_name}"
      ]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.jobs_state_bucket}/*"
    ]
  }

  statement {
    sid = "AllowCloudFrontOACAccountWide"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.jobs_state_bucket}/*"
    ]

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = [
        "arn:aws:cloudfront::${var.aws_account_id}:distribution/*"
      ]
    }
  }
}
