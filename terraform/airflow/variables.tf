variable "environment" {
  type = string
}

variable "namespace" {
  type    = string
  default = "airflow"
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "domain_name" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "rds_instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "certificate_arn" {
  type = string
}

variable "security_group_id" {
  type = string
}
