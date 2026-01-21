resource "aws_autoscaling_group" "this" {
  name                = title(var.project_name)
  vpc_zone_identifier = var.vpc_private_subnet_ids
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1

  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup = 100
    }
    triggers = ["tag"]
  }

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  target_group_arns = [aws_lb_target_group.this.arn]

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Release version"
    propagate_at_launch = false
    value               = aws_launch_template.this.latest_version
  }
}
