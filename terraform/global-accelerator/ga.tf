resource "aws_globalaccelerator_accelerator" "this" {
  name            = "${var.environment}-${lower(replace(var.name, " ", "-"))}"
  ip_address_type = "IPV4"
  enabled         = true

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-${lower(replace(var.name, " ", "-"))}"
  }
}
