resource "aws_s3_bucket" "state_results" {
  bucket        = var.jobs_state_bucket
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.state_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.state_results.id
  policy = data.aws_iam_policy_document.s3_state_access_policy.json
}
