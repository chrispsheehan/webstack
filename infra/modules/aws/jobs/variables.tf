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

variable "project_name" {
  description = "Name of project - used in naming"
  type        = string
}

variable "deploy_version" {
  description = "Version of the website to be deployed"
  type        = string
}

variable "lambda_bucket" {
  description = "S3 bucket to pull lambda code from"
  type        = string
}

variable "cost_explorer_lambda_zip" {
  description = "Lambda code (zipped) to be deployed"
  type        = string
  default     = "cost_explorer.zip"
}

variable "jobs_state_bucket" {
  description = "S3 bucket store results state"
  type        = string
}
