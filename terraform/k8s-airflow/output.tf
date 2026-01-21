output "airflow_bucket" {
  value = aws_s3_bucket.airflow.bucket
}

output "user_access_key" {
  value = aws_iam_access_key.airflow.id
}

output "user_access_secret" {
  value = aws_iam_access_key.airflow.secret
}
