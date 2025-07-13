variable "namespace" {
  type    = string
  default = "cert-manager"
}

variable "email" {
  type = string
}

variable "letsencrpyt_testing_url" {
  type    = string
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "letsencrpyt_prod_url" {
  type    = string
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "testing" {
  type    = bool
  default = false
}

variable "dns_resolver" {
  type = string
}

variable "dns_resolver_token" {
  type = string
}
