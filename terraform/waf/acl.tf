resource "aws_wafv2_web_acl" "this" {
  name        = "${replace(var.name, " ", "-")}-waf"
  description = "WAF Web ACL for ${title(var.name)}"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${replace(title(var.name), " ", "")}WAFAclMetrics"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "block-specific-ips"
    priority = 1

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${replace(title(var.name), " ", "")}BlacklistedIps"
      sampled_requests_enabled   = false
    }

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklist.arn
      }
    }
  }

  rule {
    name     = "whitelist-ips"
    priority = 2

    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${replace(title(var.name), " ", "")}WhitelistedIps"
      sampled_requests_enabled   = false
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelist.arn
      }
    }
  }

  rule {
    name     = "country-lock"
    priority = 3

    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${replace(title(var.name), " ", "")}AllowedCountry"
      sampled_requests_enabled   = false
    }

    statement {
      geo_match_statement {
        country_codes = var.allowed_country_codes
      }
    }
  }
}
