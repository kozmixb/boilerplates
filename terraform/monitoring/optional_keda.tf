resource "aws_iam_role" "cloudwatch_agent" {
  name = "${title(var.environment)}KedaRole"
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
            "${var.eks_oidc_provider}:sub" : "system:serviceaccount:support:keda-operator"
            "${var.eks_oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "helm_release" "cloudwatch_agent" {
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  name       = "keda"
  version    = "2.17.2"
  namespace  = var.namespace

  set {
    name  = "podIdentity.aws.irsa.enabled"
    value = true
  }

  set {
    name  = "podIdentity.aws.irsa.roleArn"
    value = aws_iam_role.cloudwatch_agent.arn
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "prometheus.operator.enabled"
    value = true
  }

  set {
    name  = "prometheus.operator.serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "resources.operator.requests.memory"
    value = "150Mi"
  }
}
