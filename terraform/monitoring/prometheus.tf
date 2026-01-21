resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.namespace
  create_namespace = true
  version          = "75.10.0"
  values = sensitive([
    yamlencode({
      alertmanager = local.prometheus_alerts
      grafana      = local.grafana_config
      prometheus = {
        prometheusSpec = {
          containers = [
            {
              name = "prometheus"
              startupProbe = {
                failureThreshold = 300
              }
            }
          ]
          disableCompaction                       = true
          retention                               = "14d"
          replicas                                = 1
          retentionSize                           = "40GB"
          serviceMonitorSelectorNilUsesHelmValues = false
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessMode       = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "60Gi"
                  }
                }
              }
              metadata = {
                name = "prometheus"
              }
            }
          }
          ruleSelectorNilUsesHelmValues = false
          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [
                  {
                    matchExpressions = [
                      {
                        key      = "topology.kubernetes.io/zone"
                        operator = "In"
                        values   = ["${var.aws_region}a"]
                      }
                    ]
                  }
                ]
              }
            }
          }
          additionalScrapeConfigs = yamldecode(file("${path.module}/prometheus-scrape-config.yaml"))
          resources = {
            requests = {
              cpu    = "150m"
              memory = "2Gi"
            }
            limits = {
              cpu    = "300m"
              memory = "2Gi"
            }
          }
        }
      }
      "prometheus-node-exporter" = {
        resources = {
          requests = {
            cpu    = "10m"
            memory = "100Mi"
          }
        }
      }
      kubeScheduler = {
        enabled = false
      }
      kubeControllerManager = {
        enabled = false
      }
    })
  ])
  timeout = 2000
}
