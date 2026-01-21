resource "aws_servicequotas_service_quota" "daily_quota" {
  count = var.set_quotas ? 1 : 0

  quota_code   = "L-804C8AE8"
  service_code = "ses"
  value        = var.daily_quota
}

resource "aws_servicequotas_service_quota" "rate" {
  count = var.set_quotas ? 1 : 0

  quota_code   = "L-CDEF9B6B"
  service_code = "ses"
  value        = var.sending_rate
}
