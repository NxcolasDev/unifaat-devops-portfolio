# Aula 12 — Rollback e AIOps

## Conteudo

- `src/feature-flags.js`: flags `FF_*` com parser restrito.
- `src/app.js`: demonstracao da flag no endpoint de pedidos; `/flags` fica indisponivel em producao.
- `migrations/`: duas migracoes aditivas `up/down/verify`, runner transacional e CLI.
- `scripts/`: health check, deploy, rollback e empacotamento da Lambda.
- `.github/workflows/cd-with-rollback.yml`: build ECR, deploy remoto, health check e rollback condicional.
- `terraform/observability.tf`: alarme fixo, anomaly detection e encaminhamento EventBridge para Lambda.
- `lambda-aiops/`: analise opcional via Bedrock e simulador local.

## Validacao local

```bash
npm ci
npm test
node lambda-aiops/local-simulator.js
```

O simulador e deterministico e nao acessa AWS. Para executar migracoes, use um PostgreSQL descartavel e defina `DATABASE_URL`:

```bash
npm run migrate -- status
npm run migrate -- up
npm run migrate -- down
```

`down` remove somente a coluna adicionada pela ultima migracao; os campos anteriores do pedido permanecem.

## CI/CD e AWS

Configure no ambiente protegido `aula-12` os secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `DEPLOY_HOST`, `DEPLOY_SSH_USER`, `DEPLOY_SSH_KEY`, `DEPLOY_SSH_KNOWN_HOSTS` e `HEALTH_URL`. A EC2 deve usar `LabInstanceProfile` para autenticar no ECR e publicar metricas. As credenciais do Learner Lab expiram; atualize-as localmente no ambiente autorizado, nunca no repositorio.

Para validar observabilidade, primeiro gere o pacote da Lambda:

```bash
bash scripts/package-lambda.sh
cd terraform
terraform init
terraform validate
terraform plan
```

Terraform usa a role existente `LabRole`; nao cria role IAM. Bedrock e opcional: informe `bedrock_model_id` apenas se o modelo estiver habilitado na conta/regiao. Sem ele, a Lambda usa regras deterministicas.

## Evidencias reais pendentes

- Aplicar os alarmes no Learner Lab e capturar os dois alarmes no console.
- Executar um deploy que falhe health check para observar o rollback no workflow.
- Demonstrar a flag mudando o comportamento com containers em execucao.
- Executar `up/down/status` contra um banco de teste e registrar a saida.
- Registrar a invocacao da Lambda AWS ou, se Bedrock/Lambda nao estiver disponivel, anexar a saida do simulador local.

Nao sao incluidos screenshots ficticios nem resultados de AWS nao executados.
