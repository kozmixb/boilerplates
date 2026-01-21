locals {
  groups = {
    default = []
    projects = [
      {
        key    = "app-group"
        value  = "projects"
        effect = "NoSchedule"
      }
    ]
  }
}

resource "kubernetes_manifest" "karpenter_node_template" {
  depends_on = [helm_release.karpenter]
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      kubelet = {
        imageGCHighThresholdPercent = 65
        imageGCLowThresholdPercent  = 50
      }
      amiFamily = "AL2023"
      amiSelectorTerms = [
        {
          id = var.ami_image_id
        }
      ]
      role = var.initial_group_iam_role_name
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      blockDeviceMappings = [
        {
          deviceName = "/dev/xvda"
          ebs = {
            volumeSize          = "50Gi"
            volumeType          = "gp3"
            deleteOnTermination = true
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
    }
  }
  field_manager {
    force_conflicts = true
  }
}

resource "kubernetes_manifest" "nodepool" {
  depends_on = [helm_release.karpenter]
  for_each   = local.groups

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = each.key
    }
    spec = {
      template = {
        metadata = {
          labels = {
            app-group = each.key
          }
        }
        spec = {
          requirements = [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = var.ec2_arch
              }, {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = var.ec2_os
              }, {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = var.ec2_capacity_type
              }, {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = var.ec2_instance_type
            }
          ]
          nodeClassRef = {
            name  = kubernetes_manifest.karpenter_node_template.manifest.metadata.name
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
          }
          taints      = each.value
          expireAfter = "168h"
        }
      }
      limits = {
        cpu = 1000
      }
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "1h"
        budgets = [
          # On Weekdays during business hours, don't do any deprovisioning regarding drift.
          {
            nodes    = "0"
            schedule = "0 7 * * mon-fri"
            duration = "12h"
            reasons  = ["Drifted", "Underutilized"]
          },
          # during non-business hours do drift for up to 1 of nodes
          {
            nodes = "1"
          },
        ]
      }
    }
  }
  field_manager {
    force_conflicts = true
  }
}
