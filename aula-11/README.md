# Aula 11 — Canary

O diretorio contem o Terraform do ALB/target groups, o script de rollout e o workflow manual de deploy.

1. Copie `terraform.tfvars.example` para `terraform.tfvars` e substitua os IDs de VPC, subnets e instancias do Learner Lab.
2. Execute `terraform init`, `terraform validate` e `terraform plan` em `aula-11/terraform`.
3. Aplique somente depois de revisar o plano e confirmar que os recursos cabem no Lab.
4. Configure os secrets do workflow descritos abaixo.
5. Execute `Deploy TechNova Canary` manualmente e acompanhe os health checks.

O workflow precisa de `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `CANARY_HOST`, `CANARY_SSH_USER`, `CANARY_SSH_KEY`, `CANARY_SSH_KNOWN_HOSTS`, `LISTENER_ARN`, `TG_STABLE_ARN`, `TG_CANARY_ARN` e `ALB_DNS`. A chave SSH e as credenciais temporarias nao devem ser commitadas. A EC2 canary deve ter `LabInstanceProfile` para autenticar no ECR.

O script tambem depende do AWS CLI, `jq` e `curl`. O rollout amostra respostas do endpoint de health; nao substitui alarmes de negocio em producao.
