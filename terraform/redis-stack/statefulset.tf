resource "kubernetes_stateful_set_v1" "this" {
  metadata {
    name      = "redis-stack"
    namespace = var.namespace
  }
  spec {
    selector {
      match_labels = {
        app = "redis-stack"
      }
    }
    service_name = "redis-stack"
    replicas     = var.replicas
    template {
      metadata {
        labels = {
          app = "redis-stack"
        }
      }
      spec {
        termination_grace_period_seconds = 10
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "DoNotSchedule"
          label_selector {
            match_labels = {
              app = "redis-stack"
            }
          }
        }
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "app"
                  operator = "In"
                  values   = ["redis-stack"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }
        container {
          name    = "redis-stack"
          image   = var.image
          command = ["/bin/bash", "-c"]
          args = [
            <<-EOT
              [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
              ordinal=$${BASH_REMATCH[1]}
              echo $ordinal
              ARGS="--requirepass $REDIS_MASTER_PASSWORD --masterauth $REDIS_MASTER_PASSWORD --user $REDIS_USERNAME on >$REDIS_PASSWORD ~* +@all --user default off"

              if [[ $ordinal -eq 0 ]]; then
                echo "Starting as Master"
                exec /entrypoint.sh $ARGS
              else
                echo "Starting as Replica of redis-stack-0"
                # We point to the stable DNS name of the first pod
                exec /entrypoint.sh $ARGS --replicaof redis-stack-0 6379
              fi
            EOT
          ]
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.this.metadata[0].name
            }
          }
          port {
            container_port = 6379
            name           = "db"
          }
          port {
            container_port = 8001
            name           = "insight"
          }

          volume_mount {
            name       = "db"
            mount_path = "/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "db"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "4Gi"
          }
        }
      }
    }
  }
}
