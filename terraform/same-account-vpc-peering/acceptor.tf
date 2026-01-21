resource "aws_security_group_rule" "acceptor_ingress" {
  for_each = toset(var.acceptor_security_group_ids)

  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = each.value
  cidr_blocks       = [var.requestor_cidr_block]
}
