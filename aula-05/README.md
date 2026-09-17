# Aula 05 - RDS e Remote State

Infraestrutura da TechNova com VPC, EC2 publico, RDS PostgreSQL privado e state remoto em S3 com locking no DynamoDB.

## Estrutura

- `backend/`: bootstrap temporario do bucket S3 e da tabela DynamoDB.
- `vpc.tf`: VPC, subnets, Internet Gateway e rota publica.
- `security.tf`: Security Groups da EC2 e do RDS.
- `rds.tf`: DB Subnet Group e RDS PostgreSQL.
- `ec2.tf`: EC2 `t2.micro`, key pair e cliente `psql`.
- `providers.tf`: provider e backend S3.

## Execucao

1. Gere uma chave SSH em `~/.ssh/technova-key` se ainda nao existir.
2. Crie `terraform.tfvars` localmente com a senha do banco:

```hcl
db_password       = "SENHA_FORTE_LOCAL"
ssh_ingress_cidr  = "SEU_IP_PUBLICO/32"
```

3. Carregue as credenciais temporarias do Learner Lab no terminal, sem versionar o arquivo de credenciais.
4. Entre em `backend/`, execute `terraform init`, `terraform apply` e anote os outputs do bucket e da tabela.
5. Substitua `REPLACE_WITH_STATE_BUCKET` e `REPLACE_WITH_LOCK_TABLE` em `providers.tf` pelos outputs reais.
6. Execute `terraform init -migrate-state`, confirme `yes`, e depois `terraform validate` e `terraform plan`.
7. Aplique a infraestrutura principal, conecte por SSH à EC2 e valide o RDS com `psql`.

## Evidencias

```bash
aws s3 ls s3://SEU_BUCKET/aula-05/
terraform state list
terraform plan
psql -h ENDPOINT -U technova_admin -d technova -c "SELECT version();"
psql -h ENDPOINT -U technova_admin -d technova -c "SELECT * FROM orders;"
```

Depois de capturar as evidencias, destrua primeiro a infraestrutura principal. Esvazie as versoes do bucket S3 e destrua o projeto `backend/`. Nunca versionar `terraform.tfvars`, `.tfstate`, `.terraform/`, `*.pem` ou credenciais.