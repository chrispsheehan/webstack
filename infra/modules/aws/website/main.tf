resource "aws_acm_certificate" "web_cert" {
  provider = aws.domain_aws_region

  domain_name               = var.domain
  subject_alternative_names = local.domain_records
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "web_validatation" {
  for_each = {
    for dvo in aws_acm_certificate.web_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.this.id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "web" {
  provider = aws.domain_aws_region

  certificate_arn         = aws_acm_certificate.web_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.web_validatation : record.fqdn]
}

resource "aws_s3_bucket" "state_results" {
  bucket        = var.jobs_state_bucket
  force_destroy = true
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

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${local.reference}"
  description                       = "OAC Policy for ${local.reference} static web files"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  provider   = aws.domain_aws_region
  depends_on = [aws_s3_bucket.website_logs]

  enabled         = true
  is_ipv6_enabled = true
  aliases         = local.domain_records

  default_root_object = local.root_file

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.website_logs.bucket_regional_domain_name
  }

  origin {
    domain_name              = data.aws_s3_bucket.website_files.bucket_regional_domain_name
    origin_id                = data.aws_s3_bucket.website_files.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_path              = "/${var.deploy_version}"
  }

  origin {
    domain_name              = aws_s3_bucket.state_results.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.state_results.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  custom_error_response {
    //needs to be better
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/${local.root_file}"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.web_cert.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/data/*"
    target_origin_id       = aws_s3_bucket.state_results.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 60
    compress    = true
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = data.aws_s3_bucket.website_files.bucket_regional_domain_name
  }
}

resource "aws_s3_bucket_policy" "website_files_policy" {
  bucket = data.aws_s3_bucket.website_files.id
  policy = data.aws_iam_policy_document.website_files_policy.json
}

resource "aws_s3_bucket" "website_logs" {
  bucket        = var.web_logs_bucket
  force_destroy = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "website_logs" {
  depends_on = [
    aws_s3_bucket_policy.website_logs_policy
  ]

  bucket = aws_s3_bucket.website_logs.id

  rule {
    id     = "log"
    status = "Enabled"
    filter {
      prefix = ""
    }

    expiration {
      days = var.log_retention_days
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "website_logs" {
  bucket = aws_s3_bucket.website_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "website_logs_policy" {
  bucket = aws_s3_bucket.website_logs.id
  policy = data.aws_iam_policy_document.website_logs_policy.json
}

resource "aws_route53_record" "web" {
  for_each = {
    for index, record in local.domain_records : index => record
  }

  zone_id = data.aws_route53_zone.this.id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}