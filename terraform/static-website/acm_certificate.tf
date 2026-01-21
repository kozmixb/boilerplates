resource "aws_acm_certificate" "this" {
  count = length(var.domain_name) > 0 && var.certificate_arn == null ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.aliases
  validation_method         = "DNS"
  provider                  = aws.virginia

  tags = {
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
