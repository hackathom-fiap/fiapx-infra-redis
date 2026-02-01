output "redis_endpoint" {
  description = "Endpoint primário do grupo de replicação Redis"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  description = "Porta do grupo de replicação Redis"
  value       = aws_elasticache_replication_group.redis.port
}

output "elasticache_user_group_id" {
  description = "O ID do grupo de usuários do ElastiCache."
  value       = aws_elasticache_user_group.default.id
}

output "elasticache_user_name" {
  description = "O nome do usuário padrão do ElastiCache."
  value       = aws_elasticache_user.default.user_name
}

output "elasticache_user_password_secret_arn" {
  description = "ARN do segredo no AWS Secrets Manager que contém a senha do usuário."
  value       = aws_secretsmanager_secret.user_password.arn
}
