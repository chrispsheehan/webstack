data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  name = var.root_domain
}

data "aws_iam_policy_document" "website_files_policy" {

  version = "2012-10-17"
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_files.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.distribution.arn]
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
      values   = ["${aws_cloudfront_distribution.distribution.arn}"]
    }
  }
}
