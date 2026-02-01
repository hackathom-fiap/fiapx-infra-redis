terraform {
  backend "s3" {
    bucket         = "meu-eks-terraform-state"
    key            = "fiapx-infra-redis/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "meu-eks-terraform-lock-001"
  }
}
