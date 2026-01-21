resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-target-group"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path = "/webhook/"
  }
}


resource "aws_lb_listener_rule" "https" {
  listener_arn = var.https_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}
