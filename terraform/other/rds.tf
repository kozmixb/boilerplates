resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "eks_to_rds_mysql" {
  name        = "${var.environment}-eks-to-rds-mysql"
  description = "Allow inbound traffic from EKS cluster to RDS MySQL database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
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

resource "aws_rds_cluster" "rds_mysql" {
  for_each = var.databases

  cluster_identifier          = "${var.environment}-${each.key}-cluster"
  manage_master_user_password = true
  master_username             = "admin"
  engine                      = "aurora-mysql"
  engine_version              = each.value.engine_version
  db_subnet_group_name        = aws_db_subnet_group.rds_subnet_group.name
  deletion_protection         = each.value.deletion_protected
  storage_encrypted           = true

  vpc_security_group_ids = [aws_security_group.eks_to_rds_mysql.id]
  availability_zones     = var.azs

  backup_retention_period      = 7
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "mon:04:00-mon:04:30"

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.environment}-${each.key}-db-snap-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  enabled_cloudwatch_logs_exports = ["audit", "error", "general"]

  tags = {
    Name = "${var.environment}-${each.key}"
  }

  lifecycle {
    ignore_changes = [
      engine_version,
      final_snapshot_identifier
    ]
  }
}

resource "aws_rds_cluster_instance" "write_replica" {
  for_each = var.databases

  cluster_identifier  = aws_rds_cluster.rds_mysql[each.key].cluster_identifier
  engine              = aws_rds_cluster.rds_mysql[each.key].engine
  identifier          = "${var.environment}-${each.key}-instance"
  instance_class      = each.value.instance_class
  availability_zone   = "${var.aws_region}a"
  publicly_accessible = false
  promotion_tier      = 0

  lifecycle {
    replace_triggered_by = [
      aws_rds_cluster.rds_mysql
    ]
  }
}

resource "aws_route53_record" "mysql_write_endpoint" {
  depends_on = [aws_rds_cluster.rds_mysql]
  for_each   = var.databases

  name    = "${each.key}-db"
  type    = "CNAME"
  ttl     = 300
  zone_id = var.dns_zone_id
  records = [aws_rds_cluster.rds_mysql[each.key].endpoint]
}

resource "aws_route53_record" "mysql_read_endpoint" {
  depends_on = [aws_rds_cluster.rds_mysql]
  for_each   = var.databases

  name    = "${each.key}-read-db"
  type    = "CNAME"
  ttl     = 300
  zone_id = var.dns_zone_id
  records = [aws_rds_cluster.rds_mysql[each.key].reader_endpoint]
}

resource "aws_rds_cluster_instance" "read_replica" {
  for_each = var.database_replica_enabled ? var.databases : tomap({})

  cluster_identifier  = aws_rds_cluster.rds_mysql[each.key].cluster_identifier
  engine              = aws_rds_cluster.rds_mysql[each.key].engine
  identifier          = "${var.environment}-${each.key}-ro-instance"
  instance_class      = each.value.instance_class
  availability_zone   = "${var.aws_region}b"
  publicly_accessible = false
  promotion_tier      = 1
}
