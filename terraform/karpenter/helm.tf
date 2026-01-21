locals {
  # CRD must match with karpenter release
  karpenter_chart_version = "1.3.3"
}

resource "helm_release" "karpenter-crd" {
  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter-crd"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter-crd"
  version          = local.karpenter_chart_version
  wait             = true
  values           = []
}

resource "helm_release" "karpenter" {
  depends_on       = [aws_iam_role.karpenter_controller_role, helm_release.karpenter-crd]
  name             = "karpenter"
  chart            = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  version          = local.karpenter_chart_version
  namespace        = "karpenter"
  create_namespace = true
  cleanup_on_fail  = true
  skip_crds        = true

  set {
    name  = "replicas"
    value = 2
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role.arn
  }

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "settings.featureGates.spotToSpotConsolidation"
    value = true
  }

  set {
    name  = "settings.interruptionQueue"
    value = aws_sqs_queue.karpenter_queue.name
  }
}
