resource "aws_efs_file_system" "persistence" {
  creation_token = "${replace(title(var.cluster_name), "-", "")}-persistance"
  encrypted      = true
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    eks_addon   = "aws-efs-csi-driver"
    Environment = var.environment
    Name        = "${var.cluster_name}-persistance"
    Group       = "projects"
  }
}

resource "aws_efs_mount_target" "persistence" {
  for_each = toset(data.aws_subnets.private_subnets.ids)

  file_system_id  = aws_efs_file_system.persistence.id
  subnet_id       = each.value
  security_groups = [aws_security_group.this.id]
}

resource "kubernetes_storage_class_v1" "persistence" {
  depends_on = [aws_efs_file_system.this, kubernetes_annotations.gp2]

  metadata {
    name = "efs-persistence"
  }
  parameters = {
    provisioningMode      = "efs-ap"
    fileSystemId          = aws_efs_file_system.persistence.id
    directoryPerms        = "700"
    subPathPattern        = "/$${.PVC.name}"
    ensureUniqueDirectory = false
  }
  storage_provisioner    = "efs.csi.aws.com"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
}

output "persistence_storage_class_name" {
  value = kubernetes_storage_class_v1.persistence.metadata[0].name
}
