variable "aws_region" {
  description = "Region to which resources will be deployed"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account to which resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
