variable "namespace" {
  type = string
}

variable "replicas" {
  type    = number
  default = 2
}

variable "image" {
  type    = string
  default = "redis/redis-stack-server:7.4.0-v6"
}
