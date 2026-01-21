
resource "aws_globalaccelerator_listener" "https" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}


resource "aws_globalaccelerator_endpoint_group" "https" {
  listener_arn                  = aws_globalaccelerator_listener.https.id
  endpoint_group_region         = var.aws_region
  health_check_interval_seconds = 30
  health_check_path             = "/healthz"
  health_check_port             = 443
  health_check_protocol         = "HTTPS"
  threshold_count               = 3
  traffic_dial_percentage       = 100

  endpoint_configuration {
    endpoint_id                    = var.alb_arn
    weight                         = 255
    client_ip_preservation_enabled = true
  }
}
