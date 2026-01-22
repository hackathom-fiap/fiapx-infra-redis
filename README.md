# Infraestrutura do Redis com Terraform e GitHub Actions

Este projeto provisiona um cluster Redis (AWS ElastiCache) usando Terraform e automatiza o deploy com GitHub Actions.

A senha para o cluster Redis é **gerada automaticamente** e armazenada de forma segura no **AWS Secrets Manager**.

## Passos para o Deploy

### 1. Crie um usuário IAM na AWS

Para que o GitHub Actions possa se autenticar na sua conta AWS, você precisa de um usuário IAM com as permissões necessárias.

- **Crie um usuário IAM:** No console da AWS, vá para o serviço IAM e crie um novo usuário.
- **Anexe permissões:** Para este projeto, o usuário precisará de permissões para gerenciar VPC, ElastiCache e Secrets Manager. Para simplificar, você pode anexar a política gerenciada `AdministratorAccess`.
  - **Atenção:** Para produção, é altamente recomendável criar uma política com permissões mais restritas.
- **Gere as chaves de acesso:** Crie uma chave de acesso (Access Key ID e Secret Access Key) para este usuário.

### 2. Configure os Segredos no GitHub

O workflow do GitHub Actions precisa das chaves de acesso para se autenticar na AWS.

1.  Vá para o seu repositório no GitHub.
2.  Clique em **Settings** > **Secrets and variables** > **Actions**.
3.  Clique em **New repository secret** para adicionar os seguintes segredos:
    -   `AWS_ACCESS_KEY_ID`: Cole a "Access Key ID" do seu usuário IAM.
    -   `AWS_SECRET_ACCESS_KEY`: Cole a "Secret Access Key" do seu usuário IAM.

### 3. Faça o Push para o Repositório

Com os arquivos no repositório e os segredos configurados, envie o código.

```bash
git add .
git commit -m "feat: Implementa geração automática de senha com Secrets Manager"
git push
```

### 4. Acompanhe o Deploy

Ao fazer o push para a branch `main`, o workflow do GitHub Actions será acionado. Acompanhe o processo na aba **Actions** do seu repositório.

### 5. Como Encontrar a Senha e o Endpoint do Redis

Após o deploy, a senha **não** ficará visível nos logs do GitHub. Você deve recuperá-la diretamente do AWS Secrets Manager.

#### Usando o Console da AWS

1.  Vá para o serviço **AWS Secrets Manager** no console.
2.  Procure pelo segredo com o nome `/fiapx-redis/redis/auth_token` (ou similar, baseado no `project_name`).
3.  Clique no segredo e depois em **"Retrieve secret value"** para ver a senha.

#### Usando a AWS CLI

Você pode usar o ARN do segredo (que aparece nos outputs do Terraform) para buscar a senha.

```bash
# Exemplo de como obter o ARN do output do Terraform
SECRET_ARN=$(terraform output -raw redis_auth_token_secret_arn)

# Comando para buscar o valor do segredo
aws secretsmanager get-secret-value --secret-id $SECRET_ARN --query SecretString --output text
```

O endpoint do Redis pode ser obtido via output do Terraform:

```bash
terraform output redis_endpoint
```
