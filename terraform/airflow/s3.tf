resource "aws_s3_bucket" "airflow" {
  bucket = "${var.environment}-data-reports"

  tags = {
    Environment   = var.environment
    BackupEnabled = false
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "airflow" {
  bucket = aws_s3_bucket.airflow.bucket

  versioning_configuration {
    status = "Enabled"
  }
}
