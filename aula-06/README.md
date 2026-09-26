# Biblioteca de Módulos Terraform — TechNova

Esta biblioteca contém módulos reutilizáveis para provisionamento padronizado de ambientes da TechNova.

## Módulos Disponíveis

### 1. VPC (`modules/vpc`)
Cria uma VPC completa com suporte a subnets públicas/privadas via `for_each`, Internet Gateway e Tabela de Roteamento.
- **Inputs:** `vpc_cidr`, `project_name`, `environment`, `subnets`
- **Outputs:** `vpc_id`, `public_subnet_ids`, `private_subnet_ids`

### 2. Security Group (`modules/security-group`)
Módulo genérico para criação de SGs com regras dinâmicas de entrada.
- **Inputs:** `name`, `vpc_id`, `ingress_rules`, `environment`, `project_name`
- **Outputs:** `sg_id`

### 3. EC2 (`modules/ec2`)
Cria instâncias EC2 configuráveis.
- **Inputs:** `instance_name`, `ami_id`, `subnet_id`, `security_group_ids`, `instance_type`
- **Outputs:** `instance_id`, `public_ip`, `private_ip`

### 4. RDS (`modules/rds`)
Cria banco de dados PostgreSQL em subnets privadas com DB Subnet Group.
- **Inputs:** `db_name`, `db_username`, `db_password`, `subnet_ids`, `security_group_ids`
- **Outputs:** `db_endpoint`, `db_name`, `db_port`

## Como Validar

```bash
cd environments/dev
terraform init
terraform validate
terraform plan