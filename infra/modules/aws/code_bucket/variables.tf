variable "web_bucket" {
  description = "S3 bucket to host static web files"
  type        = string
}

variable "lambda_bucket" {
  description = "S3 bucket to host lambda code files"
  type        = string
}
