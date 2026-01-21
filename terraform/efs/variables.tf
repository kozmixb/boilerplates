variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "cidr" {
  description = "CIDR block"
  type        = list(string)
}

variable "eks_oidc_provider_arn" {
  description = "oidc provider id for eks"
  type        = string
}
