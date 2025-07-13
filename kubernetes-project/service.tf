resource "kubernetes_service_v1" "this" {
  metadata {
    name      = "${var.name}-service"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = var.name
    }

    port {
      name        = "http"
      port        = 80
      target_port = var.container_port
    }
  }
}
