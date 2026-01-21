resource "aws_iam_role" "this" {
  name                 = join("", [replace(title(aws_s3_bucket.this.bucket), "-", ""), "DeployerRole"])
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
    name = join("", [replace(title(aws_s3_bucket.this.bucket), "-", ""), "DeployerPolicy"])
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "s3:ListBucket",
          ],
          Effect = "Allow",
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.this.bucket}",
          ]
        },
        {
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
          ],
          Effect = "Allow",
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
          ]
        },
        {
          Action = [
            "cloudfront:CreateInvalidation",
            "cloudfront:GetInvalidation",
            "cloudfront:ListInvalidations"
          ],
          Effect = "Allow",
          Resource = [
            "arn:aws:cloudfront::${var.aws_account_id}:distribution/*"
          ]
        },
      ]
    })
  }
}
