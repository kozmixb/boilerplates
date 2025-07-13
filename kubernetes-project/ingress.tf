resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = "${var.name}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"    = "traefik"
      "cert-manager.io/cluster-issuer" = "letsencrypt"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
    }
  }
  spec {
    tls {
      hosts = var.tls_domains
      secret_name = "${var.name}-tls"
    }
    rule {
      host = var.domain_name
      http {
        path {
          path      = var.domain_path
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.this.metadata[0].name
              port {
                number = "80"
              }
            }
          }
        }
      }
    }
  }
}
