resource "kubernetes_persistent_volume_claim_v1" "this" {
  count = length(var.volumes)

  metadata {
    name      = "${var.name}-pvc-${count.index}"
    namespace = var.namespace
  }

  spec {
    access_modes = [var.storage_access_mode]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
    volume_mode        = "Filesystem"
    storage_class_name = var.storage_class_name
  }
}
