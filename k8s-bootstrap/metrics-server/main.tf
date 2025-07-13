resource "helm_release" "this" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = var.namespace
  create_namespace = false

  set {
    name  = "metrics.enabled"
    value = true
  }

  set {
    name  = "apiService.insecureSkipTLSVerify"
    value = true
  }

  set_list {
    name = "defaultArgs"
    value = [
      "--kubelet-insecure-tls",
      "--cert-dir=/tmp",
      "--kubelet-preferred-address-types=InternalIP",
      "--kubelet-use-node-status-port", "--metric-resolution=15s"
    ]
    # --secure-port=10250 --cert-dir=/tmp --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname   --authorization-always-allow-paths=/metrics
  }
}
