################################################################################
# Requestor
################################################################################
variable "requestor_vpc_id" {
  description = "requestor vpc id"
  type        = string
}

################################################################################
# Acceptor
################################################################################
variable "acceptor_account_id" {
  description = "acceptor VPC account id"
  type        = string
}

variable "acceptor_aws_region" {
  description = "acceptor aws region"
  type        = string
}

variable "acceptor_vpc_id" {
  description = "acceptor vpc id"
  type        = string
}

variable "acceptor_cidr_block" {
  description = "acceptor cidr block"
  type        = string
}
