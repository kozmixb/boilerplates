################################################################################
# Account
################################################################################
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "production"
}

variable "github_oidc_domain" {
  description = "Github OIDC Domain"
  type        = string
  default     = "token.actions.githubusercontent.com"
}

################################################################################
# Project
################################################################################
variable "project_name" {
  description = "project name"
  type        = string
}

variable "project_prefix" {
  description = "prefix for buckets and projects"
  type        = string
  default     = "itc-prod-"
}

variable "is_nextjs_app" {
  description = "viewer forwarding rule for nextjs apps"
  type        = bool
  default     = false
}

################################################################################
# S3
################################################################################
variable "versioning_enabled" {
  description = "Versioning enabled"
  type        = bool
  default     = true
}

variable "backup_enabled_tag" {
  description = "Tag to enable backup on bucket"
  type        = bool
  default     = true
}

################################################################################
# GitHub
################################################################################
variable "github_repo" {
  description = "GitHub repository"
  type        = string
}

################################################################################
# Domain
################################################################################
variable "domain_name" {
  description = "Website Domain name"
  type        = string
  default     = ""
}

variable "aliases" {
  description = "Domain aliases"
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "certificate ARN"
  type        = string
  nullable    = true
  default     = null
}
