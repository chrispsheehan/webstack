variable "aws_account_id" {
  description = "AWS account id resources are deployed to"
  type        = string
}

variable "aws_region" {
  description = "AWS region resources are deployed to"
  type        = string
}

variable "environment" {
  description = "Name of environment i.e. dev, prod etc"
  type        = string
}

variable "root_domain" {
  description = "Root domain matching the AWS hosted zone name"
  type        = string
}

variable "log_retention_days" {
  description = "How long to keep cloudfront s3 logs before deletion"
  type        = number
  default     = 1
}
