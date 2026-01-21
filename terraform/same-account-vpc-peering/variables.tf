################################################################################
# Default
################################################################################
variable "aws_region" {
  description = "AWS region for vpc peering"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

################################################################################
# Acceptor VPC data
################################################################################
variable "acceptor_vpc_id" {
  description = "Infrastructure VPC id"
  type        = string
}

variable "acceptor_security_group_ids" {
  description = "Infrastructure VPC security ids"
  type        = list(string)
}

variable "acceptor_cidr_block" {
  description = "Infrastructure VPC cird block"
  type        = string
}

variable "acceptor_routing_ids" {
  description = "Infrastructure routing ids"
  type        = list(string)
}

################################################################################
# Acceptor VPC data
################################################################################
variable "requestor_vpc_id" {
  description = "Account VPC id"
  type        = string
}

variable "requestor_cidr_block" {
  description = "Account VPC cird block"
  type        = string
}

variable "requestor_routing_ids" {
  description = "Account VPC default route table id"
  type        = list(string)
}
