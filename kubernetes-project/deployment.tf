resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = "${var.name}-deployment"
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }
  spec {
    selector {
      match_labels = {
        "app" = var.name
      }
    }
    template {
      metadata {
        labels = {
          "app" = var.name
        }
      }
      spec {
        container {
          name              = var.name
          image             = "${var.container_image}:${var.container_image_version}"
          image_pull_policy = "Always"
          port {
            name           = "http"
            protocol       = "TCP"
            container_port = var.container_port
          }
          dynamic "env_from" {
            for_each = kubernetes_secret_v1.env

            content {
              secret_ref {
                name = kubernetes_secret_v1.env[0].metadata[0].name
              }
            }
          }
          dynamic "volume_mount" {
            for_each = kubernetes_persistent_volume_claim_v1.this

            content {
              mount_path = var.volumes[volume_mount.key]
              name       = "mount-${volume_mount.key}"
            }
          }
        }
        dynamic "volume" {
          for_each = kubernetes_persistent_volume_claim_v1.this

          content {
            name = "mount-${volume.key}"
            persistent_volume_claim {
              claim_name = volume.value.metadata[0].name
            }
          }
        }
      }
    }
  }
}
