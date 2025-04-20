output "bucket_web" {
  value = aws_s3_bucket.web.bucket
}

output "bucket_lambda" {
  value = aws_s3_bucket.lambda.bucket
}
