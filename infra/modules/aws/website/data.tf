data "aws_route53_zone" "this" {
  name = var.root_domain
}

data "aws_s3_bucket" "website_files" {
  bucket = var.website_bucket
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
