output "s3_bucket_name" {
  value = aws_s3_bucket.website_files.bucket
}

output "s3_logs_bucket_name" {
  value = aws_s3_bucket.website_logs.bucket
}

output "s3_logs_bucket_arn" {
  value = aws_s3_bucket.website_logs.arn
}

output "distribution_id" {
  value = aws_cloudfront_distribution.distribution.id
}
