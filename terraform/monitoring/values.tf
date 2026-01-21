variable "namespace" {
  description = "namespace"
  type        = string
  default     = "support"
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "eks_oidc_provider" {
  description = "EKS OIDC provider"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "oidc provider id for eks"
  type        = string
}

variable "aws_region" {
  type = string
}
