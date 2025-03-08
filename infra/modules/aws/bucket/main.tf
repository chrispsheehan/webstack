resource "aws_s3_bucket" "this" {
  bucket = var.lambda_code_bucket
}
