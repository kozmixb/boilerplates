resource "aws_security_group" "this" {
  name        = "${replace(title(var.cluster_name), "-", "")}-efs-storage"
  description = "Allow traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "nfs"
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    cidr_blocks = var.cidr
  }

  lifecycle {
    ignore_changes = [ingress]
  }
}
