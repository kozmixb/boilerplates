resource "aws_iam_role" "this" {
  name                 = join("", [title(var.project_name), "DeployerRole"])
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.github_oidc_domain}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:itccompliance/${var.github_repo}:*"
          }
        }
      },
    ]
  })

  inline_policy {
    name = join("", [title(var.project_name), "DeployerPolicy"])
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "ecr:GetAuthorizationToken",
          ],
          Effect   = "Allow",
          Resource = "*"
        },
        {
          Action = [
            "ecr:CompleteLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:InitiateLayerUpload",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage"
          ],
          Effect   = "Allow",
          Resource = aws_ecr_repository.this.arn
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
          ],
          Effect = "Allow",
          Resource = [
            "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:prod/compliance-satis-*"
          ]
        },
        {
          Action = [
            "autoscaling:StartInstanceRefresh",
          ],
          Effect   = "Allow",
          Resource = aws_autoscaling_group.this.arn
        },
      ]
    })
  }
}

resource "aws_iam_role" "ec2" {
  name = join("", [title(var.project_name), "Role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  inline_policy {
    name = "AllowEcrAccess"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage"
          ],
          Resource = aws_ecr_repository.this.arn
        },
        {
          Effect   = "Allow"
          Action   = "ecr:GetAuthorizationToken"
          Resource = "*"
        }
      ]
    })
  }
}
