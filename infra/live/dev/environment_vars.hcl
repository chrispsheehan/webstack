locals {
  log_retention_days = 2
}

inputs = {
  log_retention_days = local.log_retention_days
}
