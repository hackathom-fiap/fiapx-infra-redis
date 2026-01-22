output "redis_endpoint" {
  description = "Endpoint primário do cluster Redis"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Porta do cluster Redis"
  value       = aws_elasticache_cluster.redis.port
}

output "redis_auth_token_secret_arn" {
  description = "ARN do segredo no AWS Secrets Manager que contém a senha do Redis"
  value       = aws_secretsmanager_secret.redis_auth_token.arn
}
