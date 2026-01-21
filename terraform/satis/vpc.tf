locals {
  ssm_names = [
    "com.amazonaws.${var.aws_region}.ec2messages",
    "com.amazonaws.${var.aws_region}.ssm",
    "com.amazonaws.${var.aws_region}.ssmmessages",
  ]
}

data "aws_vpc_endpoint" "ec2_ssm" {
  for_each = toset(local.ssm_names)
  filter {
    name   = "service-name"
    values = [each.value]
  }
}

resource "aws_vpc_endpoint_security_group_association" "ec2_ssm" {
  for_each = data.aws_vpc_endpoint.ec2_ssm

  vpc_endpoint_id   = each.value.id
  security_group_id = aws_security_group.this.id
}
