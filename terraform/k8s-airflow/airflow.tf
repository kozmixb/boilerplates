resource "kubernetes_namespace_v1" "airflow" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  name       = "apache-airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  version    = "1.18.0"

  namespace        = kubernetes_namespace_v1.airflow.metadata[0].name
  create_namespace = false

  values = [jsonencode({
    revisionHistoryLimit = 7
    webserverSecretKey   = sha256("${var.environment}-airflow")
    executor             = "CeleryExecutor"
    ingress = {
      web = {
        enabled          = true
        ingressClassName = "alb"
        pathType         = "Prefix"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"                              = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"                         = "ip"
          "alb.ingress.kubernetes.io/group.name"                          = "${var.environment}-restricted"
          "alb.ingress.kubernetes.io/listen-ports"                        = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
          "alb.ingress.kubernetes.io/ssl-redirect"                        = "443"
          "alb.ingress.kubernetes.io/load-balancer-attributes"            = "deletion_protection.enabled=true"
          "alb.ingress.kubernetes.io/certificate-arn"                     = var.certificate_arn
          "alb.ingress.kubernetes.io/security-groups"                     = var.security_group_id
          "alb.ingress.kubernetes.io/manage-backend-security-group-rules" = "true"
          "alb.ingress.kubernetes.io/healthcheck-protocol"                = "HTTP"
          "alb.ingress.kubernetes.io/healthcheck-port"                    = "8080"
          "alb.ingress.kubernetes.io/healthcheck-path"                    = "/health"
          "alb.ingress.kubernetes.io/healthcheck-interval-seconds"        = "15"
          "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"         = "10"
          "alb.ingress.kubernetes.io/healthy-threshold-count"             = "3"
          "alb.ingress.kubernetes.io/unhealthy-threshold-count"           = "3"
        }
        host = "airflow.${var.domain_name}"
      }
    }
    config = {
      celery = {
        worker_concurrency = 1
      }
      logging = {
        logging_level = "DEBUG"
      }
    }
    extraEnvFrom = yamlencode([
      {
        secretRef = {
          name = kubernetes_secret_v1.variables.metadata[0].name
        }
      }
    ])
    data = {
      metadataConnection = {
        user     = try(jsondecode(data.aws_secretsmanager_secret_version.git_sync.secret_string)["POSTGRESQL_USERNAME"], "")
        pass     = try(jsondecode(data.aws_secretsmanager_secret_version.git_sync.secret_string)["POSTGRESQL_PASSWORD"], "")
        protocol = "postgresql"
        host     = aws_rds_cluster.postgres.endpoint
        port     = 5432
        db       = aws_rds_cluster.postgres.database_name
        sslmode  = "disable"
      }
    }
    workers = {
      livenessProbe = {
        enabled = false
      }
      waitForMigrations = {
        enabled = false
      }
      resources = {
        requests = {
          cpu    = "500m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
      }
      hpa = {
        enabled         = true
        minReplicaCount = 1
        maxReplicaCount = 8
        metrics = [
          {
            type = "Resource"
            resource = {
              name = "cpu"
              target = {
                type               = "Utilization"
                averageUtilization = 75
              }
            }
          }
        ]
      }
    }
    dags = {
      persistence = {
        enabled = false
      }
      gitSync = {
        enabled           = true
        repo              = try(jsondecode(data.aws_secretsmanager_secret_version.git_sync.secret_string)["GITSYNC_REPO"], "")
        branch            = try(jsondecode(data.aws_secretsmanager_secret_version.git_sync.secret_string)["GITSYNC_BRANCH"], "")
        rev               = "HEAD"
        depth             = 1
        subPath           = ""
        credentialsSecret = kubernetes_secret_v1.git_sync.metadata[0].name
        resources = {
          limits = {
            cpu    = "50m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "30m"
            memory = "50Mi"
          }
        }
      }
    }
    scheduler = {
      livenessProbe = {
        initialDelaySeconds = 86400
        periodSeconds       = 86400
        timeoutSeconds      = 86400
      }
      resources = {
        limits = {
          cpu    = "500m"
          memory = "1Gi"
        }
        requests = {
          cpu    = "200m"
          memory = "500Mi"
        }
      }
    }
    airflow = {
      config = {
        AIRFLOW__CORE__DAGS_FOLDER = "/usr/local/airflow/dags/src"
      }
    }
    postgresql = {
      enabled = false
    }
    createUserJob = {
      useHelmHooks   = false
      applyCustomEnv = false
    }
    migrateDatabaseJob = {
      useHelmHooks   = false
      applyCustomEnv = false
    }
  })]
}
