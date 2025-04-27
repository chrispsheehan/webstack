resource "aws_s3_bucket" "web" {
  bucket        = var.web_bucket
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "web" {
  depends_on = [aws_s3_bucket.web]
  bucket     = aws_s3_bucket.web.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket" "lambda" {
  bucket        = var.lambda_bucket
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "lambda" {
  depends_on = [aws_s3_bucket.lambda]
  bucket     = aws_s3_bucket.lambda.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
