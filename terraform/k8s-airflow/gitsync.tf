data "aws_secretsmanager_secret" "git_sync" {
  name = "${var.environment}/airflow"
}

data "aws_secretsmanager_secret_version" "git_sync" {
  secret_id = data.aws_secretsmanager_secret.git_sync.id
}

resource "kubernetes_secret_v1" "git_sync" {
  metadata {
    name      = "airflow-git-credentials"
    namespace = kubernetes_namespace_v1.airflow.metadata[0].name
  }
  data = {
    GITSYNC_USERNAME  = try(jsondecode(data.aws_secretsmanager_secret_version.git_sync.secret_string)["GITSYNC_USERNAME"], "")
    GITSYNC_PASSWORD  = try(jsondecode(data.aws_secretsmanager_secret_version.git_sync.secret_string)["GITSYNC_PASSWORD"], "")
    GIT_SYNC_USERNAME = try(jsondecode(data.aws_secretsmanager_secret_version.git_sync.secret_string)["GITSYNC_USERNAME"], "")
    GIT_SYNC_PASSWORD = try(jsondecode(data.aws_secretsmanager_secret_version.git_sync.secret_string)["GITSYNC_PASSWORD"], "")
  }
}
