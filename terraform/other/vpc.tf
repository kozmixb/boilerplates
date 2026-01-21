module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "account-default-vpc"
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}

locals {
  services = {
    "ec2messages" : {
      "name" : "com.amazonaws.${var.aws_region}.ec2messages"
    },
    "ssm" : {
      "name" : "com.amazonaws.${var.aws_region}.ssm"
    },
    "ssmmessages" : {
      "name" : "com.amazonaws.${var.aws_region}.ssmmessages"
    }
  }
}

resource "aws_vpc_endpoint" "ec2_ssm" {
  for_each = local.services

  vpc_id              = module.vpc.vpc_id
  service_name        = each.value.name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  subnet_ids          = module.vpc.private_subnets
}

resource "aws_vpc_endpoint_security_group_association" "ec2_ssm" {
  for_each = aws_vpc_endpoint.ec2_ssm

  security_group_id = aws_security_group.jumpbox.id
  vpc_endpoint_id   = each.value.id
}
