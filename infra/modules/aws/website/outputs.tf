output "s3_logs_bucket_name" {
  value = aws_s3_bucket.website_logs.bucket
}

output "s3_logs_bucket_arn" {
  value = aws_s3_bucket.website_logs.arn
}

output "distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "domain" {
  value = var.domain
}
