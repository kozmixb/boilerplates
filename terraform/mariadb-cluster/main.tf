resource "helm_release" "crds" {
  name       = "mariadb-operator-crds"
  repository = "https://helm.mariadb.com/mariadb-operator"
  chart      = "mariadb-operator-crds"
  namespace  = var.namespace
  version    = "25.10.4"
}

resource "helm_release" "operator" {
  name       = "mariadb-operator"
  repository = "https://helm.mariadb.com/mariadb-operator"
  chart      = "mariadb-operator"
  namespace  = var.namespace
  version    = "25.10.4"
}

resource "random_password" "root" {
  length  = 32
  special = false
  numeric = true
  upper   = true
  lower   = true
}

resource "kubernetes_secret_v1" "mariadb" {
  metadata {
    name      = "mariadb-environment"
    namespace = var.namespace
  }
  data = {
    password = random_password.root.result
  }
}

resource "kubernetes_manifest" "mariadb" {
  depends_on = [helm_release.crds, helm_release.operator]

  manifest = {
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "MariaDB"
    metadata = {
      name      = "mariadb-instance"
      namespace = var.namespace
    }
    spec = {
      replicas = 2
      replication = {
        enabled = true
      }
      image = "mariadb:11.4"

      rootPasswordSecretKeyRef = {
        name = kubernetes_secret_v1.mariadb.metadata[0].name
        key  = "password"
      }

      securityContext = {
        allowPrivilegeEscalation = false
        capabilities = {
          drop = ["ALL"]
        }
      }

      storage = {
        size             = "10Gi"
        storageClassName = "local-path"
      }
      service = {
        type = "ClusterIP"
      }
    }
  }
}
