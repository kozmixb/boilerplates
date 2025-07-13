variable "namespace" {
  description = "Namespace"
  type        = string
  default     = "default"
}

variable "name" {
  description = "Name of the project"
  type        = string
}

# #################################################
# # External
# #################################################

variable "external_ip" {
  description = "external ip address"
  type        = string
}

variable "external_port" {
  description = "Port on the external service"
  type        = string
}

variable "external_protocol" {
  description = "Protocol used by external service"
  type        = string
  default     = "TCP"
}

# #################################################
# # Domain
# #################################################
variable "domain_name" {
  description = "Domain name"
  type        = string
}
