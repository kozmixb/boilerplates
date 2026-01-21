variable "name" {
  description = "Name of waf"
  type        = string
  default     = "default web"
}

variable "allowed_ip_cidr_blocks" {
  description = "Map of IP address categories to allow"
  type        = map(list(string))
}

variable "blacklist" {
  description = "blacklist cidrs"
  type        = list(string)
  default     = []
}

variable "allowed_country_codes" {
  description = "Allow traffic from countries"
  type        = list(string)
}
