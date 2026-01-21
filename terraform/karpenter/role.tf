data "aws_caller_identity" "current" {}

resource "aws_iam_role" "karpenter_controller_role" {
  name = "${title(var.environment)}KarpenterControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.eks_oidc_provider}:aud" = "sts.amazonaws.com"
            "${var.eks_oidc_provider}:sub" = "system:serviceaccount:karpenter:karpenter"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "karpenter_controller" {
  name        = "${title(var.environment)}KarpenterControllerPolicy"
  path        = "/"
  description = "Karpenter controller policy for autoscaling"
  policy = jsonencode({
    "Statement" = [
      {
        "Action" = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts",
          "ec2:TerminateInstances"
        ],
        "Effect"   = "Allow",
        "Resource" = "*",
        "Sid"      = "Karpenter"
      },
      {
        "Action" = "ec2:TerminateInstances",
        "Condition" = {
          "StringLike" = {
            "ec2:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        },
        "Effect"   = "Allow",
        "Resource" = "*",
        "Sid"      = "ConditionalEC2Termination"
      },
      {
        "Effect"   = "Allow",
        "Action"   = "iam:PassRole",
        "Resource" = var.initial_group_iam_role_arn,
        "Sid"      = "PassNodeIAMRole"
      },
      {
        "Effect"   = "Allow",
        "Action"   = "eks:DescribeCluster",
        "Resource" = "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}",
        "Sid"      = "EKSClusterEndpointLookup"
      },
      {
        "Effect" = "Allow",
        "Action" = [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ],
        "Resource" = aws_sqs_queue.karpenter_queue.arn,
        "Sid"      = "AllowInterruptionQueueActions"
      },
      {
        "Sid"      = "AllowScopedInstanceProfileCreationActions",
        "Effect"   = "Allow",
        "Resource" = "*",
        "Action" = [
          "iam:CreateInstanceProfile"
        ],
        "Condition" = {
          "StringEquals" = {
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}" = "owned",
            "aws:RequestTag/topology.kubernetes.io/region"             = var.aws_region
          },
          "StringLike" = {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        "Sid"      = "AllowScopedInstanceProfileTagActions",
        "Effect"   = "Allow",
        "Resource" = "*",
        "Action" = [
          "iam:TagInstanceProfile"
        ],
        "Condition" = {
          "StringEquals" = {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}" = "owned",
            "aws:ResourceTag/topology.kubernetes.io/region"             = var.aws_region,
            "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"  = "owned",
            "aws:RequestTag/topology.kubernetes.io/region"              = var.aws_region
          },
          "StringLike" = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*",
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"  = "*"
          }
        }
      },
      {
        "Sid"      = "AllowScopedInstanceProfileActions",
        "Effect"   = "Allow",
        "Resource" = "*",
        "Action" = [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ],
        "Condition" = {
          "StringEquals" = {
            "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}" = "owned",
            "aws:ResourceTag/topology.kubernetes.io/region"             = var.aws_region
          },
          "StringLike" = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        "Sid"      = "AllowInstanceProfileReadActions",
        "Effect"   = "Allow",
        "Resource" = "*",
        "Action"   = "iam:GetInstanceProfile"
      }
    ],
    "Version" = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.karpenter_controller.arn
  role       = aws_iam_role.karpenter_controller_role.name
}
