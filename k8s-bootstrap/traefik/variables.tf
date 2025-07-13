variable "namespace" {
  type    = string
  default = "traefik"
}

variable "whitelisted_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "service_annotations" {
  type    = map(string)
  default = {}
}
