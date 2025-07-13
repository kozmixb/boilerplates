resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "this" {
  metadata {
    name = "external-dns-envs"
  }
  type = "Opaque"
  data = {
    token = var.dns_resolver_token
  }
}

resource "helm_release" "this" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.18.0" #
  namespace  = kubernetes_namespace_v1.this.metadata[0].name

  # Install CRDs as part of the Helm release (recommended)
  set {
    name  = "crds.enabled"
    value = true
  }

  set {
    name  = "clusterResourceNamespace"
    value = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_manifest" "this" {
  count = helm_release.this.status == "deployed" ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt"
    }
    spec = {
      acme = {
        email  = var.email
        server = var.testing ? var.letsencrpyt_testing_url : var.letsencrpyt_prod_url
        privateKeySecretRef = {
          name = "letsencrypt-prod-account-key"
        }
        solvers = [
          {
            dns01 = {
              var.dns_resolver = {
                tokenSecretRef = {
                  name = kubernetes_secret_v1.this.metadata[0].name
                  key  = "token"
                }
              }
            }
          }
        ]
      }
    }
  }

  field_manager {
    force_conflicts = true
  }
}
