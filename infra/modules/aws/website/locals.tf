locals {
  domain_records = [
    var.domain
  ]
  reference   = replace(var.domain, ".", "-")
  bucket_name = "${var.aws_account_id}-${var.aws_region}-${var.environment}-${local.reference}"
  root_file   = "index.html"
  api_origin  = "${local.reference}-reference"
}
