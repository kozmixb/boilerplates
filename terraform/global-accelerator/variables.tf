variable "environment" {
  description = "Environment"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "name" {
  description = "Global accelerator name"
  type        = string
}

variable "alb_arn" {
  description = "application load balancer identifier"
  type        = string
}
