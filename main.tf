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

# Gera uma senha aleatória para o Redis
resource "random_password" "redis_auth_token" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Cria o segredo no AWS Secrets Manager
resource "aws_secretsmanager_secret" "redis_auth_token" {
  name = "/${var.project_name}/redis/auth_token"
  tags = {
    Name = "${var.project_name}-redis-auth-token"
  }
}

# Armazena a senha gerada no segredo
resource "aws_secretsmanager_secret_version" "redis_auth_token" {
  secret_id     = aws_secretsmanager_secret.redis_auth_token.id
  secret_string = random_password.redis_auth_token.result
}

# Cria uma VPC para isolar nossos recursos
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Cria uma subnet dentro da VPC
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = "${var.project_name}-subnet"
  }
}

# Cria um grupo de segurança para o cluster Redis
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Permite acesso à porta do Redis"
  vpc_id      = aws_vpc.main.id

  # Permite tráfego de entrada na porta do Redis (6379) de qualquer lugar dentro da VPC
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
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
  subnet_ids = [aws_subnet.main.id]
}

# Cria o cluster Redis ElastiCache
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-cluster"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  auth_token           = random_password.redis_auth_token.result

  tags = {
    Name = "${var.project_name}-cluster"
  }
}
