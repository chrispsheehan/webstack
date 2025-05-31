variable "aws_account_id" {
  description = "AWS account id resources are deployed to"
  type        = string
}

variable "lambda_api_name" {
  description = "Name of API lambda"
  type = string
}

variable "lambda_cost_explorer_name" {
  description = "Name of cost explorer lambda"
  type = string
}

variable "jobs_state_bucket" {
  description = "S3 bucket store results state"
  type        = string
}
