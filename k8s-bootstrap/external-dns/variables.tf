variable "namespace" {
  type = string
  default = "default"
}

variable "domain_zone" {
  type = string
}

variable "provider" {
  description = "domain provider"
  type = string
}

variable "domain_txt_owner_id" {
  type = string

}

variable "envs" {
  type = map(string)
}
