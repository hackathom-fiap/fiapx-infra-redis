# Este é um arquivo de exemplo. Renomeie para terraform.tfvars e preencha com seus valores.
# O arquivo terraform.tfvars não deve ser enviado para o controle de versão (Git).

# Região da AWS para criar os recursos (ex: "us-east-1")
aws_region = "us-east-1" 

# Nome do projeto para usar em tags e nomes de recursos (ex: "fiapx-redis-proj")
project_name = "fiapx-redis"

# O ID da VPC existente que você deseja usar (ex: "vpc-0123456789abcdef0")
vpc_id = "vpc-8ce247f1"

# A lista de IDs de subnets existentes onde o cluster ElastiCache será implantado.

subnet_ids = ["subnet-c3f47da5", "subnet-8a652684"]

# Tipo de nó para o cluster Redis ElastiCache (ex: "cache.t2.micro")
redis_node_type = "cache.t3.micro"
