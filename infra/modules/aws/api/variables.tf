variable "aws_account_id" {
  description = "AWS account id resources are deployed to"
  type        = string
}

variable "aws_region" {
  description = "AWS region resources are deployed to"
  type        = string
}

variable "root_domain" {
  description = "Root domain matching the AWS hosted zone name"
  type        = string
}

variable "api_key_ssm" {
  description = "Name of ssm param used to store api key"
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

variable "lambda_bucket" {
  description = "S3 bucket to pull lambda code from"
  type        = string
}

variable "lambda_zip" {
  description = "Lambda code (zipped) to be deployed"
  type        = string
}

variable "auth_lambda_bucket" {
  description = "S3 bucket to pull auth lambda code from"
  type        = string
}

variable "auth_lambda_zip" {
  description = "Lambda auth code (zipped) to be deployed"
  type        = string
}
