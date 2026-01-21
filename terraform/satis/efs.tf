resource "aws_efs_file_system" "efs" {
  creation_token   = "${var.project_name}-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = var.project_name
  }
}

resource "aws_security_group" "efs" {
  description = "Security Group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "EFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.this.id]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.this.id]
  }
}

resource "aws_efs_mount_target" "efs" {
  for_each        = toset(var.vpc_private_subnet_ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}
