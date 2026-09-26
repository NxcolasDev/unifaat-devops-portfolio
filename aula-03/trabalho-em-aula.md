# Trabalho em Aula - Aula 03: Terraform e IAM

**Aluno:** Nicolas de Jesus Silva
**RA:** 6325171  
**Data:** 10/09/2026

## Infraestrutura como Codigo

IaC permite declarar a infraestrutura em arquivos versionados, reproduzi-la e revisar alteracoes antes da aplicacao. O `terraform plan` mostra o que sera criado, alterado ou destruido sem executar a mudanca.

## Principio do menor privilegio

Cada identidade deve receber somente as permissoes necessarias para sua funcao. Na estrutura TechNova, desenvolvedores recebem leitura de S3, a equipe de plataforma recebe operacoes especificas de EC2 condicionadas pela tag `Project=TechNova`, e existe um `Deny` explicito para acoes destrutivas.

## Users, groups e roles

- Juliana pertence ao grupo de desenvolvedores.
- Rafael pertence aos grupos de desenvolvedores e plataforma.
- Lucas pertence somente ao grupo de desenvolvedores.
- A role de EC2 pode ser assumida por `ec2.amazonaws.com` e usa Instance Profile, evitando access keys fixas.

## Console AWS versus Terraform

O Console e util para explorar a AWS, mas e manual e dificil de auditar. Terraform registra a configuracao em codigo, permite revisao por Pull Request e facilita a recriacao da infraestrutura.

## Cuidados de seguranca

Credenciais temporarias do AWS Academy nao devem ser colocadas no repositorio. O estado Terraform tambem deve permanecer fora do Git porque pode conter informacoes sensiveis.
