locals {
  environment_tags   = ["*"]
  log_retention_days = 14
}

inputs = {
  environment_tags   = local.environment_tags
  log_retention_days = local.log_retention_days
}
