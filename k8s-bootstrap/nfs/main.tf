resource "helm_release" "this" {
  name             = "nfs-provisioner"
  repository       = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"
  chart            = "nfs-subdir-external-provisioner"
  namespace        = var.namespace
  create_namespace = false

  set {
    name  = "nfs.server"
    value = var.nfs_server_ip
  }

  set {
    name  = "nfs.path"
    value = var.nfs_server_path
  }

  set {
    name  = "storageClass.name"
    value = var.nfs_storage_class_name
  }
}
