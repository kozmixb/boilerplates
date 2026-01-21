# resource "helm_release" "kubecost" {
#   name             = "kubecost"
#   namespace        = var.namespace
#   chart            = "oci://public.ecr.aws/kubecost/cost-analyzer"
#   version          = "2.7.1"
#   create_namespace = true
#
#   values = [yamlencode({
#     global = {
#       prometheus = {
#         enabled = false
#         fqdn    = "http://prometheus-kube-prometheus-prometheus.support.svc:9090"
#         nodeExporter = {
#           enabled = false
#         }
#         kube-state-metrics = {
#           disabled = true
#         }
#         serviceAccounts = {
#           nodeExporter = {
#             create = false
#           }
#         }
#       }
#       grafana = {
#         enabled = false
#         proxy   = false
#       }
#     }
#     kubecostModel = {
#       resources = {
#         requests = {
#           cpu    = "200m"
#           memory = "100Mi"
#         }
#         limits = {
#           cpu    = "800m"
#           memory = "256Mi"
#         }
#       }
#     }
#     kubecostProductConfigs = {
#       metricsConfigs = {
#         disabledMetrics = [
#           "kube_node_status_condition",
#           "kube_node_status_capacity",
#           "kube_node_status_allocatable",
#           "kube_deployment_spec_replicas",
#           "kube_deployment_status_replicas_available",
#           "kube_pod_owner",
#           "kube_pod_container_status_running",
#           "kube_pod_container_resource_requests",
#           "kube_pod_status_phase",
#           "kube_pod_container_status_restarts_total",
#           "kube_pod_container_resource_limits",
#           "kube_persistentvolume_capacity_bytes",
#           "kube_persistentvolume_status_phase",
#           "kube_persistentvolumeclaim_info",
#           "kube_persistentvolumeclaim_resource_requests_storage_bytes"
#         ]
#       }
#     }
#   })]
# }
