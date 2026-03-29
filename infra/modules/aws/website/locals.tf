locals {
  domain_records = [
    "www.${var.domain}",
    "${var.domain}"
  ]
  reference               = replace(var.domain, ".", "-")
  bucket_name             = "${var.aws_account_id}-${var.aws_region}-${var.environment}-${local.reference}"
  root_file               = "index.html"
  cloudfront_wildcard_arn = "arn:aws:cloudfront::${var.aws_account_id}:distribution/*"
  cloudfront_iam_values   = var.initial_deploy ? [local.cloudfront_wildcard_arn] : [try(aws_cloudfront_distribution.this.arn, local.cloudfront_wildcard_arn)]

  function_runtime = "cloudfront-js-1.0"
  append_index_html_code = templatefile(
    "${path.module}/code/append-index-to-paths.js.tpl",
    {
      version = var.deploy_version
    }
  )

  function_append_index_html = "${local.reference}-append-index-to-path"
}
