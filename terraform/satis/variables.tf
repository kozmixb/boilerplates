################################################################################
# Account
################################################################################
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "production"
}

################################################################################
# GitHub
################################################################################
variable "github_repo" {
  description = "satis github repo name"
  type        = string
  default     = "compliance-satis"
}

variable "github_oidc_domain" {
  description = "Github OIDC Domain"
  type        = string
  default     = "token.actions.githubusercontent.com"
}

################################################################################
# ECR
################################################################################
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "satis"
}

variable "image_retention" {
  description = "Number of historical images to keep"
  type        = number
  default     = 5
}

variable "container_port" {
  description = "docker container port"
  type        = number
  default     = 8080
}

################################################################################
# Domain
################################################################################
variable "domain_name" {
  description = "Website Domain name"
  type        = string
  default     = "satis.itccompliance.co.uk"
}

################################################################################
# VPC
################################################################################
variable "vpc_id" {
  description = "vpc id where alb lives"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cidrs"
  type        = string
}

variable "vpc_private_subnet_ids" {
  description = "list of private subnet ids"
  type        = list(string)
}

variable "https_listener_arn" {
  description = "https listener arn"
  type        = string
}

variable "instance_type" {
  description = "instance type"
  type        = string
  default     = "t3.micro"
}
