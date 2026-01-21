locals {
  s3_origin_id = "${aws_s3_bucket.this.bucket}-origin"
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = local.s3_origin_id
  description                       = "CloudFront S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = coalesce(var.domain_name, "Static Website")
  default_root_object = "index.html"
  aliases             = length(var.domain_name) > 0 ? distinct(concat([var.domain_name], var.aliases)) : []
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    dynamic "function_association" {
      for_each = aws_cloudfront_function.nextjs

      content {
        event_type   = "viewer-request"
        function_arn = function_association.value.arn
      }
    }

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/404.html"
  }

  viewer_certificate {
    cloudfront_default_certificate = length(var.domain_name) == 0
    acm_certificate_arn            = length(aws_acm_certificate.this) > 0 ? aws_acm_certificate.this[0].arn : var.certificate_arn
    ssl_support_method             = "sni-only"
  }

  price_class = "PriceClass_100"
  tags = {
    "Environment" = var.environment
  }
}
