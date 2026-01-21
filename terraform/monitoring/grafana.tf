resource "random_password" "grafana_admin_password" {
  length  = 21
  special = false
  upper   = true
  lower   = true
  numeric = true
}

locals {
  grafana_config = {
    enabled                  = true
    adminPassword            = random_password.grafana_admin_password.result
    defaultDashboardsEnabled = false
    forceDeployDashboards    = false
    sidecar = {
      enabled = true
      dashboards = {
        enabled = true
      }
    }
    persistence = {
      enabled          = true
      type             = "statefulset"
      storageClassName = "efs-sc"
      size             = "20Gi"
    }
    initChownData = {
      enabled = false
    }
    resources = {
      requests = {
        cpu    = "50m"
        memory = "400Mi"
      }
      limits = {
        cpu    = "70m"
        memory = "530Mi"
      }
    }
  }
}

resource "kubernetes_config_map_v1" "dashboards" {
  depends_on = [helm_release.prometheus]
  for_each   = fileset(path.module, "dashboards/*.json")

  metadata {
    name      = "grafana-custom-${basename(replace(each.value, ".json", ""))}"
    namespace = var.namespace
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    basename(each.value) = sensitive(file("${path.module}/${each.value}"))
  }
}
