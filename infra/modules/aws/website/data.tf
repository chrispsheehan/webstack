data "aws_route53_zone" "this" {
  name = var.root_domain
}

data "aws_s3_bucket" "website_files" {
  bucket = var.web_bucket
}

data "aws_ssm_parameter" "api_key" {
  name = var.api_key_ssm
}

data "aws_iam_policy_document" "website_files_policy" {

  version = "2012-10-17"
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.website_files.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

data "aws_iam_policy_document" "website_logs_policy" {
  version = "2012-10-17"

  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.website_logs.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = local.cloudfront_iam_values
    }
  }
}

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
      "${aws_s3_bucket.state_results.arn}/*"
    ]

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.this.arn
      ]
    }
  }
}
