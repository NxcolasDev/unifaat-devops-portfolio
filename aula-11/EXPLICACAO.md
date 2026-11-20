# Explicacao — Aula 11: Canary com ALB e ECR

## Opcao escolhida

Foi escolhida a Opcao B, Canary.
Uma nova versao nao recebe todo o trafego de uma vez.
Isso reduz o impacto de uma regressao na API de pedidos.
O target stable continua ativo durante toda a promocao.

## Diagrama de arquitetura

```text
GitHub Actions --build/push--> Amazon ECR
       |
       +--SSH: ECR login + docker pull--> EC2 Canary
                                              |
Clientes --> ALB Listener --> Target Group Stable
                        \--> Target Group Canary
```

O ALB fica em duas subnets publicas de Availability Zones diferentes.
O listener HTTP distribui requisicoes entre os dois target groups.
O target group stable representa a versao atualmente promovida.
O target group canary representa a versao em validacao.
O target group attachment associa cada target group a uma EC2 existente.

## Fluxo do deploy

1. Uma execucao manual do workflow recebe um limite de erro.
2. O workflow configura credenciais temporarias do AWS Academy Learner Lab.
3. O Docker constroi uma imagem identificada pelo SHA do commit.
4. A imagem e publicada no Amazon ECR.
5. A acao abre uma conexao SSH para a instancia canary.
6. A instancia usa seu instance profile do Lab para autenticar no ECR.
7. O container canary anterior e substituido pela imagem nova.
8. O workflow chama `canary-rollout.sh`.
9. O script confirma que existe pelo menos um target canary saudavel.
10. O listener comeca com 5% do trafego no canary.
11. O endpoint `/health` e amostrado pelo ALB durante a janela configurada.
12. O script calcula a taxa de respostas 5xx e compara com o limite recebido.
13. Se aprovado, o trafego progride para 25%, 50% e 100%.
14. Stickiness de 300 segundos reduz alternancia de versao dentro da sessao.
15. Cada etapa repete as verificacoes de target e erro HTTP.

## Fluxo de rollback

Se um target ficar unhealthy, a verificacao do health endpoint falhar ou a taxa de erro exceder o limite, o script para o rollout.
O listener volta para 100% stable e 0% canary.
A instancia stable nao e encerrada durante a promocao.
O workflow continua marcado como falho para exigir investigacao.
O step condicional tambem tenta restaurar os pesos estaveis se outro passo falhar.
Requests ja em andamento podem terminar no target que os recebeu.
O rollback altera o destino de novas requisicoes, nao desfaz efeitos ja gravados no banco.

## Tempo estimado por etapa

O tempo real depende do cold start do container e do intervalo de health check.
O exemplo configura 60 segundos de observacao por etapa.
O ALB pode levar cerca de 30 segundos para confirmar o estado de um target.
Quatro etapas levam aproximadamente quatro minutos, mais build e deploy.
Em producao, a janela deve ser baseada no volume e nas metricas de negocio.

## Melhorias para producao

1. Usaria OIDC com uma role IAM de curta duracao em vez de credenciais estaticas no GitHub.
2. Substituiria a amostragem de `/health` por alarmes CloudWatch de 5xx, latencia p99 e pedidos concluidos por target group.
3. Colocaria o deploy atras de uma aprovacao de ambiente e manteria auditable cada promocao.
4. Adicionaria TLS, protecao de origem e testes de integracao que validem pagamento e persistencia.
5. Usaria uma ferramenta de rollout com estado e metricas, alem de ensaios periodicos de rollback.

## Evidencias

O codigo e o plano podem ser validados localmente.
O apply, o deploy real, as capturas do ALB/ECR e a execucao de rollback precisam ser realizados no Learner Lab.
Nenhuma evidencia de recurso AWS e afirmada neste documento antes dessa execucao.
