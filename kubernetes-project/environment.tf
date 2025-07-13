resource "kubernetes_secret_v1" "env" {
  count = length(var.environment_vars) > 0 ? 1 : 0

  metadata {
    name      = "${var.name}-environment-secret"
    namespace = var.namespace
  }

  data = var.environment_vars
}
