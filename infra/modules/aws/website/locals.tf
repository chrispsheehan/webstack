locals {
  domain = var.environment == "prod" ? "wip.${var.root_domain}" : "wip.${var.environment}.${var.root_domain}"
  domain_records = [
    local.domain
  ]
  reference   = replace(local.domain, ".", "-")
  bucket_name = "${var.aws_account_id}-${var.aws_region}-${var.environment}-${local.reference}"
  root_file   = "index.html"
  api_origin  = "${local.reference}-reference"
}
