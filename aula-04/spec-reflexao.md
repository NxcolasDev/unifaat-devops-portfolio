# Reflexao - Spec-Driven para EC2 na VPC

## O que o Spec acertou?

A estrutura separou a rede do provisionamento da instancia, usou data source para a AMI, Instance Profile para a role do EC2 e outputs para IP, URL e SSH.

## O que foi revisado?

O Lab 1 tinha apenas uma subnet publica e uma privada. O TF exige quatro subnets em duas Availability Zones, por isso a estrutura foi ampliada com `for_each`. Tambem foi adicionada uma API local no `user_data.sh`, evitando depender de um repositorio externo.

## O checklist encontrou riscos?

A porta SSH deve ser restringida ao IP do administrador antes do `apply`. O NAT Gateway nao foi criado para evitar custos. Credenciais AWS e chaves privadas ficam fora do projeto.

## O User Data funciona sem ajustes?

O script instala Node.js 18, Git e Express, cria os endpoints `/`, `/health` e `/orders` e inicia o servidor na porta 3000. A confirmacao final exige testar a instancia com `curl` e consultar os logs de cloud-init.

## Comparacao com o Lab 1

O Lab 1 foi mais simples para entender os componentes isolados. O Spec acelera a composicao da arquitetura, mas a revisao humana continua necessaria para validar custos, CIDRs, regras de firewall e comandos de inicializacao.
