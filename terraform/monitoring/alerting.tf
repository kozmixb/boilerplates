data "aws_secretsmanager_secret" "prometheus_alerts" {
  name = "${var.environment}/prometheus-alertmanager"
}

data "aws_secretsmanager_secret_version" "prometheus_alerts" {
  secret_id = data.aws_secretsmanager_secret.prometheus_alerts.id
}

locals {
  prometheus_alerts = {
    alertmanagerSpec = {
      storage = {
        volumeClaimTemplate = {
          spec = {
            storageClassName = "efs-sc"
            accessModes      = ["ReadWriteOnce"]
            resources = {
              requests = {
                storage = "1Gi"
              }
            }
          }
        }
      }
    }
    config = {
      receivers = [
        {
          name = "null"
        },
        {
          name = "slack"
          slack_configs = try(jsondecode(data.aws_secretsmanager_secret_version.prometheus_alerts.secret_string)["slack_api_url"], "") == "" ? [] : [{
            api_url       = try(jsondecode(data.aws_secretsmanager_secret_version.prometheus_alerts.secret_string)["slack_api_url"], ""),
            channel       = try(jsondecode(data.aws_secretsmanager_secret_version.prometheus_alerts.secret_string)["slack_channel"], "#general")
            send_resolved = true
            title         = "[${upper(var.environment)} - {{ .Status |toUpper }}] {{ (index .Alerts 0).Labels.alertname }}"
            mrkdwn_in     = ["text"]
            fallback      = "[${upper(var.environment)} - {{ .Status |toUpper }}] {{ (index .Alerts 0).Labels.alertname }}"
            text          = <<EOT
{{ range .Alerts }}
*Severity:* `{{ .Labels.severity }}`
*Summary:* {{ .Annotations.summary }}
{{ if .Annotations.description }}*Description:* {{ .Annotations.description }}{{ end }}
{{ end }}
EOT
          }]
        },
        {
          name = "pager"
          pagerduty_configs = try(jsondecode(data.aws_secretsmanager_secret_version.prometheus_alerts.secret_string)["pagerduty_service_key"], "") == "" ? [] : [{
            service_key   = try(jsondecode(data.aws_secretsmanager_secret_version.prometheus_alerts.secret_string)["pagerduty_service_key"], "")
            send_resolved = true
          }]
        }
      ]
      route = {
        group_by        = ["alertname"]
        group_wait      = "30s"
        group_interval  = "5m"
        repeat_interval = "1h"
        routes = [
          {
            matchers = ["severity=~\"critical|warning\""]
            receiver = "slack"
            continue = true
          },
          {
            matchers = ["severity=~\"critical\""]
            receiver = "pager"
            continue = true
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "alert_oom" {
  depends_on = [helm_release.prometheus]
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "memory-alerting"
      namespace = "support"
      labels = {
        role    = "alert-rules"
        release = "prometheus"
      }
    }
    spec = {
      groups = [
        {
          name = "kube-pod"
          rules = [
            {
              alert = "PodOomKilled"
              annotations = {
                summary     = "POD Container status OOMKilled"
                description = "POD Container restarted due to OOMKilled {{$labels.pod}}"
              }
              expr = "kube_pod_container_status_last_terminated_reason{reason=\"OOMKilled\"} > 0"
              for  = "30s"
              labels = {
                severity = "critical"
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "alert_probe" {
  depends_on = [helm_release.prometheus]
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "probing-alerting"
      namespace = "support"
      labels = {
        role    = "alert-rules"
        release = "prometheus"
      }
    }
    spec = {
      groups = [
        {
          name = "blackbox"
          rules = [
            {
              alert = "BlackboxProbeFailed"
              annotations = {
                summary     = "Blackbox probe failed (instance {{ $labels.instance }})"
                description = "Probe failed\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
              }
              expr = "probe_success == 0"
              for  = "30s"
              labels = {
                severity = "critical"
              }
            },
            {
              alert = "BlackboxProbeTimeout"
              annotations = {
                summary     = "Probe timed out"
                description = "Probing application timed out on {{$labels.instance}}"
              }
              expr = "probe_http_duration_seconds > 60"
              for  = "30s"
              labels = {
                severity = "critical"
              }
            },
            {
              alert = "BlackboxProbeBadGateway"
              annotations = {
                summary     = "Probe Bad Gateway"
                description = "Bad gateway while trying to reach the following application {{$labels.instance}}"
              }
              expr = "probe_http_status_code == 503"
              for  = "30s"
              labels = {
                severity = "warning"
              }
            },
            {
              alert = "BlackboxProbeGatewayTimeout"
              annotations = {
                summary     = "Gateway Timeout"
                description = "Gateway Timeout while trying to reach the following application {{$labels.instance}}"
              }
              expr = "probe_http_status_code == 504"
              for  = "30s"
              labels = {
                severity = "warning"
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "alert_resources" {
  depends_on = [helm_release.prometheus]
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "resource-alerting"
      namespace = "support"
      labels = {
        role    = "alert-rules"
        release = "prometheus"
      }
    }
    spec = {
      groups = [
        {
          name = "container-resources"
          rules = [
            {
              alert = "CPURequestExceeded"
              annotations = {
                summary     = "CPU Resource request exceeded (instance {{ $labels.pod }})"
                description = "Following resource using more than requested\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
              }
              expr = "rate(container_cpu_usage_seconds_total[1m]) > on(container,pod) kube_pod_container_resource_requests{resource=\"cpu\"}"
              for  = "1m"
              labels = {
                severity = "warning"
              }
            },
            {
              alert = "MemoryRequestExceeded"
              annotations = {
                summary     = "Memory Resource request exceeded (instance {{ $labels.pod }})"
                description = "Following resource using more than requested\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
              }
              expr = "container_memory_working_set_bytes > on(container,pod) kube_pod_container_resource_requests{resource=\"memory\"}"
              for  = "1m"
              labels = {
                severity = "warning"
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "karpenter" {
  depends_on = [helm_release.prometheus]
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "karpenter-alerting"
      namespace = "support"
      labels = {
        role    = "alert-rules"
        release = "prometheus"
      }
    }
    spec = {
      groups = [
        {
          name = "karpenter"
          rules = [
            {
              alert = "SpotInstanceInterupted"
              annotations = {
                summary     = "AWS initiated an instance termination (pending {{ $value }})"
                description = "Spot instance interruption notice has been received from AWS, instance will be taken out of the cluster in 2 minutes"
              }
              expr = "idelta(karpenter_interruption_received_messages_total{message_type=\"spot_interrupted\",container!=\"\"}[1m]) > 0"
              for  = "30s"
              labels = {
                severity = "warning"
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "phpfpm" {
  depends_on = [helm_release.prometheus]
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "phpfpm-alerting"
      namespace = "support"
      labels = {
        role    = "alert-rules"
        release = "prometheus"
      }
    }
    spec = {
      groups = [
        {
          name = "php-fpm"
          rules = [
            {
              alert = "PHPFpmMaxChildrenReached"
              annotations = {
                summary     = "Max children reached {{ $value }}"
                description = "PHP-fpm has reached maximum children limit"
              }
              expr = "phpfpm_max_children_reached == 1"
              for  = "30s"
              labels = {
                severity = "warning"
              }
            }
          ]
        }
      ]
    }
  }
}
