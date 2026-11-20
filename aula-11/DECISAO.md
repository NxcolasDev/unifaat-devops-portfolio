# Decisao de deploy — Canary

Escolhi Canary porque a API de pedidos e critica e a refatoracao de frete/cupons pode afetar compras. O rollout comecara com uma parcela pequena do trafego e so aumenta quando os targets estao saudaveis e a taxa de erros fica dentro do limite.

## Promocao

- 5%: validar inicializacao, health check e erros HTTP.
- 25%: continuar somente se a taxa de erro permanecer abaixo do threshold informado no workflow.
- 50%: observar por mais um ciclo antes de ampliar a exposicao.
- 100%: promover a nova versao depois da verificacao final.

## Rollback

Qualquer target canary unhealthy, falha no health check ou taxa de erro amostrada maior que o threshold retorna o listener para 100% stable / 0% canary. A versao stable permanece ativa durante todo o rollout.

## Stickiness

A stickiness de 300 segundos evita que uma sessao alterne entre versoes. Como efeito colateral, a amostra de trafego pode ficar menos representativa e usuarios podem permanecer no canary ate o cookie expirar. Por isso, a promocao tambem verifica a saude do target e nao usa a amostra HTTP como unico sinal em producao.

## Limitacoes conhecidas

O script amostra o endpoint `/health` pelo ALB; isso valida disponibilidade, mas nao substitui metricas reais de negocio, latencia e erros do payment gateway. Em producao, o threshold deve usar CloudWatch/observabilidade por target group e alarmes com baseline.
