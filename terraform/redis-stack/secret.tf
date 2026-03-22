resource "random_password" "root" {
  length  = 32
  special = false
  numeric = true
  upper   = true
  lower   = true
}

resource "random_password" "user" {
  length  = 32
  special = false
  numeric = true
  upper   = true
  lower   = true
}

resource "kubernetes_secret_v1" "this" {
  metadata {
    name      = "redis-stack-environment"
    namespace = var.namespace
  }
  data = {
    REDIS_MASTER_PASSWORD = random_password.root.result
    REDIS_USERNAME        = "redis"
    REDIS_PASSWORD        = random_password.user.result
  }
}
