resource "kubernetes_cluster_role_v1" "robusta" {
  metadata {
    name = "krr-cluster-role"
  }
  rule {
    api_groups = [""]
    resources = [
      "configmaps",
      "daemonsets",
      "deployments",
      "namespaces",
      "pods",
      "replicasets",
      "replicationcontrollers",
      "services"
    ]
    verbs = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets", "deployments", "deployments/scale", "replicasets", "replicasets/scale", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["daemonsets", "deployments", "deployments/scale", "ingresses", "replicasets", "replicasets/scale", "replicationcontrollers/scale"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_service_account_v1" "robusta" {
  metadata {
    name      = "krr-service-account"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding_v1" "robusta" {
  metadata {
    name = "krr-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "krr-cluster-role"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "krr-service-account"
    namespace = var.namespace
  }
}

resource "kubernetes_job_v1" "robusta" {
  metadata {
    name      = "krr"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {
        name = "krr-job"
      }
      spec {
        container {
          name              = "krr"
          command           = ["/bin/sh", "-c", "python krr.py simple --max-workers 3 --width 2048"]
          image             = "robustadev/krr:v1.25.0"
          image_pull_policy = "Always"
          resources {
            requests = {
              memory = "2Gi"
            }
            limits = {
              memory = "2Gi"
            }
          }
        }
        restart_policy       = "Never"
        service_account_name = kubernetes_service_account_v1.robusta.metadata[0].name
      }
    }
  }
  wait_for_completion = false
}
