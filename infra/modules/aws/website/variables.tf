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

variable "domain" {
  description = "Domain to be accessible via the web"
  type        = string
}

variable "web_logs_bucket" {
  description = "Web logs bucket name"
  type        = string
}

variable "log_retention_days" {
  description = "How long to keep cloudfront s3 logs before deletion"
  type        = number
  default     = 1
}

variable "initial_deploy" {
  description = "Is this the first time the website is being deployed? If so we prevent race conditions and circular dependencies caused by IAM generation variables."
  type        = bool
  default     = true
}

variable "deploy_version" {
  description = "Version of the website to be deployed"
  type        = string
}

variable "web_bucket" {
  description = "The name of the s3 bucket hosting static web files"
  type        = string
}

variable "jobs_state_bucket" {
  description = "S3 bucket store results state"
  type        = string
}

variable "lambda_cost_explorer_name" {
  description = "Name of cost explorer lambda"
  type        = string
}