tflint {
  required_version = ">= 0.53"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

config {
  format = "compact"
  disabled_by_default = false
}
