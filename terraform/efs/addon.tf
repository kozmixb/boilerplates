data "aws_eks_addon_version" "this" {
  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = var.eks_version
}

resource "aws_eks_addon" "this" {
  cluster_name  = var.cluster_name
  addon_name    = "aws-efs-csi-driver"
  addon_version = data.aws_eks_addon_version.this.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = module.vpc_cni_irsa.iam_role_arn

  configuration_values = jsonencode({
    # Until enabled https://github.com/aws/containers-roadmap/issues/2582
    # node = {
    #   resources = {
    #     requests = {
    #       cpu = "100m"
    #       memory = "140Mi"
    #     }
    #     limits = {
    #       cpu = "100m"
    #       memory = "140Mi"
    #     }
    #   }
    # }
  })

  preserve = true

  tags = {
    cluster_name = var.cluster_name
    eks_addon    = "aws-ebs-csi-driver"
  }
}
