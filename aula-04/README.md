# Infraestrutura TechNova - Aula 04

**Aluno:** Nicolas Jesus e Silva  
**RA:** 6325171  
**Data:** 10/09/2026  
**Repositorio:** https://github.com/NXCOLASDEV/unifaat-devops-portfolio

## Arquitetura

```text
Internet
   |
Internet Gateway
   |
VPC 10.0.0.0/16
   +-- us-east-1a: public 10.0.1.0/24 -> EC2/API
   |                  private 10.0.2.0/24 -> banco/cache futuro
   +-- us-east-1b: public 10.0.3.0/24
                      private 10.0.4.0/24

Public Route Table: 0.0.0.0/0 -> Internet Gateway
Private subnets: somente rota local da VPC
```

A rede usa duas Availability Zones para distribuir os recursos e permitir crescimento. A API fica em subnet publica porque precisa receber trafego externo. Banco e cache ficam em subnets privadas e nao sao expostos diretamente.

## Recursos

| Recurso | Funcao |
|---|---|
| VPC | Rede isolada `10.0.0.0/16`. |
| 4 subnets | Duas publicas e duas privadas em duas AZs. |
| Internet Gateway | Saida e entrada da rede publica. |
| Route Table | Rota publica para o IGW. |
| API Security Group | SSH e API na porta 3000. |
| DB Security Group | PostgreSQL somente dentro da VPC. |
| EC2 t2.micro | Servidor Amazon Linux 2023 da API. |
| IAM Role/Profile | Acesso temporario do EC2 ao S3. |

## Como executar

Pre-requisitos: AWS CLI, Terraform, credenciais temporarias validas do AWS Academy e uma chave publica em `~/.ssh/technova-key.pub`.

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

O acesso SSH deve ser restringido antes do apply, por exemplo:

```bash
terraform apply -var='ssh_ingress_cidr=SEU_IP_PUBLICO/32'
```

Depois da inicializacao da instancia:

```bash
curl "$(terraform output -raw api_url)"
curl "$(terraform output -raw api_url)/health"
curl "$(terraform output -raw api_url)/orders"
terraform output -raw ssh_command
```

Ao terminar as evidencias, destrua os recursos:

```bash
terraform destroy
```

Nao use NAT Gateway neste laboratorio, pois ele gera custo.

## Decisoes de seguranca

O Security Group do banco permite PostgreSQL somente para o CIDR interno da VPC. A role do EC2 usa `AmazonS3ReadOnlyAccess` e credenciais temporarias via Instance Profile, sem access keys no codigo. O SSH e parametrizado por CIDR para permitir restricao ao IP do administrador.
