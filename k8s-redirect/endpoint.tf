resource "kubernetes_endpoints_v1" "this" {
  metadata {
    name      = "${var.name}-service"
    namespace = var.namespace
  }
  subset {
    address {
      ip = var.external_ip
    }
    port {
      name     = "http"
      port     = var.external_port
      protocol = var.external_protocol
    }
  }
}
