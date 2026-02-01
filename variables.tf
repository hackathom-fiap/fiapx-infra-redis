variable "aws_region" {
  description = "Região da AWS para criar os recursos"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto para usar em tags e nomes de recursos"
  type        = string
}

variable "vpc_id" {
  description = "O ID da VPC existente onde os recursos serão criados."
  type        = string
}

variable "subnet_ids" {
  description = "A lista de IDs de subnets existentes para o cluster ElastiCache."
  type        = list(string)
}

variable "redis_node_type" {
  description = "Tipo de nó para o cluster Redis ElastiCache"
  type        = string
}
