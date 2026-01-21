variable "daily_quota" {
  type    = number
  default = 100000
}

variable "sending_rate" {
  type    = number
  default = 50
}

variable "identities" {
  type = list(string)
  default = [
    # example.com
  ]
}

variable "set_quotas" {
  type    = bool
  default = false
}
