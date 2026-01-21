variable "environment" {
  description = "Environment"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "cluster_endpoint" {
  description = "Cluster endpoint"
  type        = string
}

variable "eks_oidc_provider" {
  description = "EKS OIDC provider"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "eks oid provider arn"
  type        = string
}

variable "initial_group_iam_role_arn" {
  description = "Initial EKS group iam role identifier"
  type        = string
}

variable "initial_group_iam_role_name" {
  description = "Initial EKS group iam role identifier"
  type        = string
}

################################################################################
# Karpenter instance scaling
################################################################################

variable "ec2_arch" {
  description = "EC2 Architecture"
  type        = list(string)
  default     = ["amd64"]
}

variable "ec2_os" {
  description = "EC2 operating system support"
  type        = list(string)
  default     = ["linux"]
}

variable "ec2_capacity_type" {
  description = "EC2 capacity type"
  type        = list(string)
  default     = ["spot", "on-demand"]
}

variable "ec2_instance_type" {
  description = "EC2 Instance types"
  type        = list(string)
}

variable "ami_image_id" {
  description = "AMI image id"
  type        = string
}
