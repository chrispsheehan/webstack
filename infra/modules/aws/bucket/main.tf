resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
}
