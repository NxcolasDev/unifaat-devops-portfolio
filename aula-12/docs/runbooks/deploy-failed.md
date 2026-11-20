# Runbook: deploy da TechNova API falhou

## Trigger

- O endpoint `/health` nao retorna HTTP 200 apos o deploy.
- A taxa de `Error5xx` excede o threshold ou o alarme de latencia entra em `ALARM`.
- O workflow `Aula 12 CD with automatic rollback` falha no health check.

## Severidade: P1

Classificar como P1 quando pedidos ou pagamentos estiverem indisponiveis. Se houver apenas degradacao sem impacto em pedidos, reclassificar com o responsavel de plantao.

## Diagnostico (< 2 min)

1. Verificar a resposta do servico: `curl -i "$HEALTH_URL"`.
2. Verificar o container no host: `docker ps -a --filter name=technova-api`.
3. Ler logs recentes: `docker logs --tail 100 technova-api`.
4. Verificar estado e motivo do alarme:
   `aws cloudwatch describe-alarms --alarm-names TechNova-Error5xx TechNova-ResponseTime-Anomaly --region us-east-1`.
5. Correlacionar o horario do deploy com timeouts do gateway e com o volume de pedidos.

## Acao imediata

1. Pausar novas promocoes e avisar o responsavel de plantao.
2. Confirmar nos logs do workflow se o rollback automatico foi executado.
3. Se o rollback automatico falhou, executar `aula-12/scripts/rollback.sh` por SSH no host de deploy. O script restaura a imagem ECR registrada antes da troca.
4. Se a integracao V2 for a causa provavel, desligar `FF_PAYMENT_GATEWAY_V2` e reiniciar o servico conforme a janela aprovada.
5. Nao executar `terraform destroy` nem apagar banco/state como tentativa de recuperacao.

## Mitigacao via feature flag

Com acesso ao ambiente seguro do deploy, definir `FF_PAYMENT_GATEWAY_V2=false` e reiniciar a aplicacao. Confirmar a flag em `/flags` somente fora de producao e validar uma transacao de teste. A rota `/flags` responde 404 em producao.

## Verificacao

- [ ] `/health` retorna HTTP 200.
- [ ] A taxa `Error5xx` voltou abaixo do threshold.
- [ ] `ResponseTime` voltou a sua faixa normal.
- [ ] Novos pedidos sao criados sem erro.
- [ ] Logs nao mostram novos timeouts do gateway.
- [ ] A versao atual do container foi anotada.

## Escalacao

Escalar para o responsavel pela API e pelo gateway imediatamente em P1. Se pedidos ou dados puderem ter sido perdidos/duplicados, acionar tambem o responsavel pelo banco. Preservar logs, metricas, SHA do deploy e horario do rollback para o postmortem.
