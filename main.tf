terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Gera uma senha aleatória para o usuário do ElastiCache
resource "random_password" "user_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Cria um usuário para o ElastiCache
resource "aws_elasticache_user" "default" {
  user_id       = "default-user"
  user_name     = "default"
  engine        = "REDIS"
  access_string = "on ~* +@all"
  passwords     = [random_password.user_password.result]
}

# Cria o segredo no AWS Secrets Manager para a senha do usuário
resource "aws_secretsmanager_secret" "user_password" {
  name = "/${var.project_name}/redis/user_password"
  tags = {
    Name = "${var.project_name}-redis-user-password"
  }
}

# Armazena a senha gerada no segredo
resource "aws_secretsmanager_secret_version" "user_password" {
  secret_id     = aws_secretsmanager_secret.user_password.id
  secret_string = random_password.user_password.result
}

# Cria um grupo de usuários para o ElastiCache e associa o usuário
resource "aws_elasticache_user_group" "default" {
  user_group_id = "${var.project_name}-user-group"
  engine        = "REDIS"
  user_ids      = [aws_elasticache_user.default.user_id]
}

# Obtém informações da VPC existente
data "aws_vpc" "existing" {
  id = var.vpc_id
}

# Cria um grupo de segurança para o cluster Redis
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Permite acesso a porta do Redis"
  vpc_id      = var.vpc_id

  # Permite tráfego de entrada na porta do Redis (6379) de qualquer lugar dentro da VPC
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.existing.cidr_block]
  }

  # Permite todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}

# Cria um grupo de subnets para o ElastiCache
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = var.subnet_ids
}

# Cria o grupo de replicação ElastiCache
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.project_name}-replication-group"
  description                   = "${var.project_name} Valkey/Redis replication group"
  engine                        = "redis"
  engine_version                = "7.0"
  node_type                     = var.redis_node_type
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  security_group_ids            = [aws_security_group.redis.id]
  user_group_ids                = [aws_elasticache_user_group.default.id]
  transit_encryption_enabled    = true
  
  # Configuração para um cluster multi-AZ com um primário e uma réplica
  num_cache_clusters          = 2
  automatic_failover_enabled    = true

  tags = {
    Name = "${var.project_name}-replication-group"
  }
}
