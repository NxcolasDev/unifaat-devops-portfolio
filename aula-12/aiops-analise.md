# Analise critica — AIOps na TechNova

## O que a automacao observa

O servico emite `ResponseTime`, `Error5xx` e `OrdersCreated` no namespace `TechNova/API`.
O alarme `TechNova-Error5xx` usa um limite fixo para detectar erros de servidor.
O alarme `TechNova-ResponseTime-Anomaly` compara a latencia com uma banda de deteccao de anomalias.
EventBridge encaminha transicoes para `ALARM` a uma Lambda executada com a role existente `LabRole`.

## Como interpretar o resultado

A Lambda pode usar Bedrock quando `BEDROCK_MODEL_ID` esta configurado e autorizado.
Sem esse parametro, a Lambda usa regras deterministicas; o simulador local usa o mesmo raciocinio.
O resultado informa severidade sugerida, causa provavel, acao e necessidade de rollback.
Uma indicacao de causa raiz e uma hipotese, nao uma prova.

## Quando confiar e quando exigir validacao

- Um alarme fixo e util para thresholds objetivos, como volume de 5xx em um periodo.
- A banda de anomalia ajuda a encontrar degradacao que varia por horario e historico.
- A IA pode resumir sinais correlacionados e sugerir o runbook a consultar.
- Um operador deve validar logs, target health e metricas de pedidos antes de uma acao irreversivel.
- Rollback autonomo nao deve alterar schema, apagar recursos ou reprocessar pagamentos sem autorizacao humana.

## Limitacoes e falsos positivos

- Pouco historico pode tornar a banda de anomalia ruidosa ou pouco representativa.
- Uma mudanca legitima de trafego pode parecer anomalia.
- `Error5xx` e latencia so ajudam se a aplicacao emitir metricas com dimensoes e unidades consistentes.
- O simulador e baseado em regras, nao e um modelo ML nem prova a integracao AWS.
- Uma LLM pode inventar correlacoes ou omitir sinais; a resposta nao deve ser executada como comando.
- Credenciais temporarias expiradas, permissoes ausentes ou falta de acesso ao modelo podem impedir a analise.
- Logs enviados a um modelo devem ser minimizados e nunca conter tokens, dados pessoais ou segredos.

## Salvaguardas

1. Manter thresholds fixos como protecao mesmo com anomaly detection.
2. Limitar a Lambda a leitura de contexto e recomendacao; exigir aprovacao humana para rollback.
3. Usar `LabRole`, credenciais temporarias e menor privilegio; nao salvar secrets no codigo.
4. Registrar alarmes, contexto sanitizado e recomendacao para auditoria.
5. Testar a resposta com cenarios locais antes de habilitar qualquer remediacao.
