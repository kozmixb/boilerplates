resource "aws_security_group" "this" {
  name   = "${var.project_name}-security-group"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    self        = "false"
    cidr_blocks = [var.vpc_cidr]
    description = "Enable HTTPS for SSM"
  }

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "TCP"
    self        = "false"
    cidr_blocks = [var.vpc_cidr]
    description = "Container port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name} security group"
  }
}
