variable "aws_region" {
  description = "Region to which resources will be deployed"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account to which resources will be deployed"
  type        = string
}

variable "root_domain" {
  description = "Domain to set in the github envirionments"
  type        = string
}

variable "deploy_role_name" {
  description = "AWS role used in ci deployments"
  type        = string
}

variable "github_repo" {
  description = "Name of a the github repo"
  type        = string
}

variable "environment" {
  description = "Name of github actions environment"
  type        = string
}

variable "environment_branches" {
  type        = list(string)
  description = "The target branches for environment to deploy from i.e main"
  default     = []
}

variable "environment_tags" {
  type        = list(string)
  description = "The target tags for environment to deploy from i.e * for all"
  default     = []
}

variable "web_bucket" {
  description = "S3 bucket to host static web files"
  type        = string
}

variable "lambda_bucket" {
  description = "S3 bucket to host lambda code files"
  type        = string
}
