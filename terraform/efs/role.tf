module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  create_role           = true
  role_name             = "${title(var.environment)}EfsCsi"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true
  attach_ebs_csi_policy = true
  attach_efs_csi_policy = true

  oidc_providers = {
    efs = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}
