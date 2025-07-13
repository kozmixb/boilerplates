variable "namespace" {
  description = "Namespace"
  type        = string
  default     = "default"
}

variable "name" {
  description = "Name of the project"
  type        = string
}

#################################################
# Container
#################################################
variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3000
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "container_image_version" {
  description = "Container image version"
  type        = string
  default     = "latest"
}

variable "environment_vars" {
  description = "Environment variables for container"
  type        = map(string)
  default     = {}
}

#################################################
# Volumes
#################################################

variable "storage_class_name" {
  type = string
  default = "nfs01"
}

variable "storage_size" {
  type = string
  default = "10G"
}

variable "storage_access_mode" {
  type = string
  default = "ReadWriteOnce"
}

variable "volumes" {
  description = "Volumes"
  type        = list(string)
  default     = []
}

#################################################
# Domain
#################################################
variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "domain_path" {
  description = "Domain path"
  type        = string
  default     = "/"
}

#################################################
# Certificate
#################################################
variable "tls_cert_name" {
  description = "TLS certification secret name"
  type        = string
}

variable "tls_domains" {
  description = "TLS default domains"
  type        = list(string)
}
