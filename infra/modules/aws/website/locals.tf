locals {
  domain = "wip.${var.root_domain}"
  domain_records = [
    local.domain
  ]
  reference = replace(local.domain, ".", "-")
  root_file = "index.html"
}
