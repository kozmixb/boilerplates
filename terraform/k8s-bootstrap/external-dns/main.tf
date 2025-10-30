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
  data = var.envs
}

resource "helm_release" "this" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.17.0"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name

  values = [yamlencode({
    domainFilters = [var.domain_zone]
    provider = {
      name = var.provider
    }

    env = [for k, v in var.envs : {
      name = k
      valueFrom = {
        secretKeyRef = {
          name = kubernetes_secret_v1.this.metadata[0].name
          key  = k
        }
      }
    }]

    logLevel = "debug"
    rbac = {
      create = true
    }
    sources    = ["ingress", "service"]
    txtOwnerId = var.domain_txt_owner_id
    })
  ]
}
