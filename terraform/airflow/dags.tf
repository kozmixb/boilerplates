data "aws_secretsmanager_secret" "dags" {
  name = "${var.environment}/airflow-dag"
}

data "aws_secretsmanager_secret_version" "dags" {
  secret_id = data.aws_secretsmanager_secret.dags.id
}

resource "kubernetes_secret_v1" "variables" {
  metadata {
    name      = "airflow-variables"
    namespace = kubernetes_namespace_v1.airflow.metadata[0].name
  }
  data = {
    AIRFLOW_CONN_AWS_DEFAULT = jsonencode({
      conn_type = "aws",
      login     = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["AWS_ACCESS_KEY"],
      password  = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["AWS_SECRET_KEY"],
      extra = {
        region_name = "eu-west-2"
      }
    }),
    S3_BUCKET = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["S3_BUCKET"],
    AIRFLOW_CONN_MYSQL_NEW = jsonencode({
      conn_type = "mysql",
      login     = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["NEW_DB_USER"],
      password  = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["NEW_DB_PASSWORD"],
      host      = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["NEW_DB_HOST"],
      port      = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["NEW_DB_PORT"]
    })
    AIRFLOW_CONN_MYSQL_LEGACY = jsonencode({
      conn_type = "mysql",
      login     = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["LEGACY_DB_USER"],
      password  = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["LEGACY_DB_PASSWORD"],
      host      = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["LEGACY_DB_HOST"],
      port      = jsondecode(data.aws_secretsmanager_secret_version.dags.secret_string)["LEGACY_DB_PORT"]
    })
  }
}
