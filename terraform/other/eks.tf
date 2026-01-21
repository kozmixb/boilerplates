data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  partition = data.aws_partition.current.partition
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name             = "${title(var.environment)}EbsCsi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_security_group" "eks" {
  name        = "${var.environment}-eks-sg"
  description = "Security Group for EKS on ${var.environment}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [ingress]
  }

  tags = {
    Name                     = "${var.environment}-eks-sg"
    Cluster                  = var.cluster_name
    "karpenter.sh/discovery" = var.cluster_name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  create_cluster_security_group            = false
  cluster_security_group_id                = aws_security_group.eks.id
  create_node_security_group               = false
  cluster_endpoint_public_access           = true
  cloudwatch_log_group_retention_in_days   = var.cloudwatch_log_retention_in_days
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        resources = {
          requests = {
            cpu    = "150m"
            memory = "70Mi"
          }
        }
        autoScaling = {
          enabled     = true
          minReplicas = var.eks_coredns_min_replica
          maxReplicas = 8
        }
      })
    }
    kube-proxy = {
      configuration_values = jsonencode({
        resources = {
          requests = {
            cpu    = "100m"
            memory = "70Mi"
          }
          limits = {
            cpu    = "300m"
            memory = "200Mi"
          }
        }
      })
    }
    vpc-cni = {
      configuration_values = jsonencode({
        resources = {
          requests = {
            cpu    = "25m"
            memory = "200Mi"
          }
        }
      })
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      configuration_values = jsonencode({
        node = {
          resources = {
            requests = {
              cpu    = "100m"
              memory = "140Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "140Mi"
            }
          }
        }
      })
    }
  }

  self_managed_node_group_defaults = {
    ami_type               = "AL2023_x86_64_STANDARD"
    ami_id                 = var.eks_ami_id
    launch_template_name   = "${var.environment}-eks-template"
    create_launch_template = true
    create_security_group  = false
    vpc_security_group_ids = [aws_security_group.eks.id]
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 50
          volume_type = "gp3"
        }
      }
    ]

    cloudinit_pre_nodeadm = [
      {
        content_type = "application/node.eks.aws"
        content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  imageGCHighThresholdPercent: 65
                  imageGCLowThresholdPercent: 50
                  shutdownGracePeriod: 30s
                  featureGates:
                    DisableKubeletCloudCredentialProviders: true
          EOT
      }
    ]

    iam_role_additional_policies = {
      ssm_policy = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    "${var.environment}-initial" = {
      min_size      = var.eks_asg_min_replica
      desired_size  = var.eks_asg_min_replica
      max_size      = 3
      instance_type = var.support_instance_class
    }
  }

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}
