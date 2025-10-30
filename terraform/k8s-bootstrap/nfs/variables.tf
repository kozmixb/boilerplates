variable "namespace" {
  type = string
}

variable "nfs_server_ip" {
  type = string
}

variable "nfs_server_path" {
  type = string
}

variable "nfs_storage_class_name" {
  type    = string
  default = "nfs01"
}

