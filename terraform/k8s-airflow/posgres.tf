resource "aws_db_subnet_group" "postgres" {
  name       = "${var.environment}-postgres-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "postgres" {
  name        = "${var.environment}-eks-to-postgres-posgres"
  description = "Allow inbound traffic from EKS cluster to RDS Postgres database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr]
  }

  tags = {
    Name = "${var.environment} RDS Access"
  }

  lifecycle {
    ignore_changes = [ingress]
  }
}

resource "aws_rds_cluster" "postgres" {
  cluster_identifier                  = "${var.environment}-airflow-cluster"
  manage_master_user_password         = true
  master_username                     = "admin"
  engine                              = "aurora-postgresql"
  db_subnet_group_name                = aws_db_subnet_group.postgres.name
  deletion_protection                 = true
  iam_database_authentication_enabled = true
  storage_encrypted                   = true
  database_name                       = "airflow"

  vpc_security_group_ids = [aws_security_group.postgres.id]
  availability_zones     = var.azs

  backup_retention_period      = 7
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "mon:04:00-mon:04:30"

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.environment}-airflow-postgres-db-snap-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  tags = {
    Name = "${var.environment}-postgres"
  }

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}

resource "aws_rds_cluster_instance" "write_replica" {
  cluster_identifier  = aws_rds_cluster.postgres.cluster_identifier
  engine              = aws_rds_cluster.postgres.engine
  identifier          = "${var.environment}-airflow-instance"
  instance_class      = var.rds_instance_class
  availability_zone   = "${var.aws_region}b"
  publicly_accessible = false
  promotion_tier      = 0

  lifecycle {
    replace_triggered_by = [
      aws_rds_cluster.postgres
    ]
  }
}
