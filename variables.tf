variable "aws_region" {
  description = "Região da AWS para criar os recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para usar em tags e nomes de recursos"
  type        = string
  default     = "fiapx-redis"
}

variable "vpc_cidr_block" {
  description = "Bloco CIDR para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "Bloco CIDR para a subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "redis_node_type" {
  description = "Tipo de nó para o cluster Redis ElastiCache"
  type        = string
  default     = "cache.t2.micro"
}
