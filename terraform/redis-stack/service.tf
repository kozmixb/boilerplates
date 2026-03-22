resource "kubernetes_service_v1" "this" {
  metadata {
    name      = "redis-stack"
    namespace = var.namespace
  }
  spec {
    cluster_ip = "None"
    port {
      name        = "redis"
      protocol    = "TCP"
      port        = 6379
      target_port = 6379
    }
    selector = {
      app = "redis-stack"
    }
  }
}
