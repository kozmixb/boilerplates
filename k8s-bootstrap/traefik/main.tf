resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  name       = "traefik-ingress-controller"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "35.3.0"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name

  values = [
    yamlencode({
      additionalArguments = [
        "--entrypoints.web.http.redirections.entryPoint.to=:443",
        "--entrypoints.web.http.redirections.entryPoint.scheme=https",
        "--entrypoints.web.http.redirections.entrypoint.permanent=true",
        "--serversTransport.insecureSkipVerify=true",
        "--api.insecure=true",
      ]
      service = {
        annotations              = var.service_annotations
        loadBalancerSourceRanges = var.whitelisted_ips
      }
      providers = {
        kubernetesCRD = {
          enabled = true
        }
        kubernetesIngress = {
          enabled      = true
          ingressClass = "traefik"
        }
      }
      ingressClass = {
        name = "traefik"
      }
      logs = {
        general = {
          level = "DEBUG"
        }
      }
    })
  ]
}
