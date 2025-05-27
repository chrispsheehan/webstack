locals {
  domain_records = [
    "www.${var.domain}",
    "${var.domain}"
  ]
  reference               = replace(var.domain, ".", "-")
  bucket_name             = "${var.aws_account_id}-${var.aws_region}-${var.environment}-${local.reference}"
  root_file               = "index.html"
  api_origin              = "${local.reference}-reference"
  cloudfront_wildcard_arn = "arn:aws:cloudfront::${var.aws_account_id}:distribution/*"
  cloudfront_iam_values   = var.initial_deploy ? [local.cloudfront_wildcard_arn] : [try(aws_cloudfront_distribution.this.arn, local.cloudfront_wildcard_arn)]
}
