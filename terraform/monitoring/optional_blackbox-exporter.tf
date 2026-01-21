resource "kubernetes_deployment" "blackbox" {
  metadata {
    name      = "blackbox-exporter"
    namespace = var.namespace
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "blackbox-exporter"
      }
    }
    template {
      metadata {
        name      = "blackbox-exporter"
        namespace = var.namespace
        labels = {
          App = "blackbox-exporter"
        }
      }
      spec {
        container {
          name              = "exporter"
          image             = "quay.io/prometheus/blackbox-exporter:v0.27.0"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 9115
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "20Mi"
            }
            limits = {
              cpu    = "10m"
              memory = "40Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "blackbox" {
  metadata {
    name      = "blackbox-exporter"
    namespace = var.namespace
    annotations = {
      "prometheus.io/port"   = 80
      "prometheus.io/scrape" = true
      "prometheus.io/path"   = "/metrics"
    }
  }
  spec {
    selector = {
      App = "blackbox-exporter"
    }
    port {
      port        = 80
      target_port = 9115
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}
