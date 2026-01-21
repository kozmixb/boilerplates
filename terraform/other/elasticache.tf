resource "aws_security_group" "eks_to_redis" {
  name        = "${var.environment}-eks-to-redis"
  description = "Allow inbound traffic from EKS cluster to Redis cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr]
  }

  lifecycle {
    ignore_changes = [ingress]
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.environment}-redis-cluster"
  description                = "${var.environment} Redis Cluster"
  engine                     = "redis"
  node_type                  = var.elasticache_node_type
  parameter_group_name       = "default.redis7"
  automatic_failover_enabled = true
  num_node_groups            = 1
  replicas_per_node_group    = var.elasticache_node_replicas
  engine_version             = "7.0"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids         = [aws_security_group.eks_to_redis.id]

  # Enable automatic backup
  final_snapshot_identifier = "${var.environment}-redis-snap-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  snapshot_retention_limit  = 1
  snapshot_window           = "00:00-01:30"
  maintenance_window        = "mon:01:30-mon:03:00"

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}

resource "aws_route53_record" "redis_endpoint" {
  count = var.dns_zone_id == null ? 0 : 1

  name    = "redis"
  type    = "CNAME"
  ttl     = 300
  zone_id = var.dns_zone_id
  records = [aws_elasticache_replication_group.redis.primary_endpoint_address]
}
