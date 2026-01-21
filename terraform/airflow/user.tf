resource "aws_iam_user" "airflow" {
  name = join("", [title(var.environment), "AirflowUser"])

  tags = {
    environment = var.environment
  }
}

resource "aws_iam_access_key" "airflow" {
  user = aws_iam_user.airflow.name
}

data "aws_iam_policy_document" "airflow" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ReplicateObject",
      "s3:DeleteObject"
    ]
    resources = [aws_s3_bucket.airflow.arn]
  }

  statement {
    actions   = ["secretsmanager:GetSecretValue", ]
    resources = ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:${var.environment}/airflow-dag"]
  }
}


resource "aws_iam_user_policy" "airflow" {
  name   = join("", [title(var.environment), "S3AirflowPolicy"])
  user   = aws_iam_user.airflow.name
  policy = data.aws_iam_policy_document.airflow.json
}
