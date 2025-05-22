# Vivares MongoDB Infrastructure

Este projeto contém a infraestrutura como código (IaC) para o ambiente de desenvolvimento do projeto Vivares.

## Recursos Criados

- Instância EC2 com MongoDB
- Bucket S3 para armazenamento de arquivos
- Security Groups
- Chaves SSH

## Pré-requisitos

- Terraform >= 1.0.0
- AWS CLI configurado
- Chave SSH

## Configuração

1. Copie o arquivo de exemplo de variáveis:
   ```bash
   cp example.tfvars terraform.tfvars
   ```

2. Edite o arquivo `terraform.tfvars` com suas configurações:
   - `key_name`: Nome da sua chave SSH
   - `public_key_path`: Caminho para sua chave pública SSH
   - `my_ip`: Seu IP público no formato CIDR (ex: 123.123.123.123/32)
   - `mongo_pass`: Senha do MongoDB

## Uso

1. Inicialize o Terraform:
   ```bash
   terraform init
   ```

2. Aplique a configuração:
   ```bash
   terraform apply
   ```

3. Para destruir a infraestrutura:
   ```bash
   terraform destroy
   ```

## Segurança

- Nunca comite o arquivo `terraform.tfvars`
- Mantenha suas chaves SSH seguras
- Use senhas fortes para o MongoDB
- Revise as políticas de segurança regularmente

## Estrutura do Projeto

```
.
├── main.tf           # Configuração principal
├── variables.tf      # Definição de variáveis
├── example.tfvars    # Exemplo de variáveis
├── .gitignore       # Arquivos ignorados pelo Git
└── README.md        # Este arquivo
``` 