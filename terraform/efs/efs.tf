resource "aws_efs_file_system" "this" {
  creation_token = "${replace(title(var.cluster_name), "-", "")}-eks-efs"
  encrypted      = true
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    eks_addon   = "aws-efs-csi-driver"
    Environment = var.environment
    Name        = "${var.cluster_name}-eks"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(data.aws_subnets.private_subnets.ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.this.id]
}

resource "kubernetes_storage_class_v1" "efs" {
  depends_on = [aws_efs_file_system.this, kubernetes_annotations.gp2]

  metadata {
    name = "efs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.this.id
    directoryPerms   = "700"
  }
  storage_provisioner = "efs.csi.aws.com"
}

output "default_storage_class_name" {
  value = kubernetes_storage_class_v1.efs.metadata[0].name
}
