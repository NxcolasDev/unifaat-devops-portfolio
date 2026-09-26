# Aula 03 - Terraform + IAM | Nicolas de Jesus Silva (RA 6325171)

**Repositorio:** https://github.com/NXCOLASDEV/unifaat-devops-portfolio

## Objetivo

Esta atividade declara a estrutura de identidade e acesso da TechNova com Terraform na AWS, usando `us-east-1`. O RA foi usado como prefixo dos nomes para evitar conflitos com outros alunos.

## Design da estrutura IAM

- `6325171-technova-developers`: grupo para os tres desenvolvedores, com leitura nos buckets `technova-*`.
- `6325171-technova-platform-eng`: grupo para operacoes de plataforma, recebido por Rafael, com leitura e escrita em S3 e controle de ciclo de vida de instancias EC2 marcadas com `Project=TechNova`.
- Juliana e Lucas pertencem somente a `developers`; Rafael pertence aos dois grupos por precisar das permissoes de desenvolvimento e plataforma.
- A policy `deny-destructive` bloqueia terminacao de instancias e exclusao de buckets/objetos para os membros de `developers`. Um `Deny` explicito prevalece sobre qualquer `Allow` recebido por outro grupo.
- A role de EC2 usa credenciais temporarias e permite somente leitura, escrita e listagem nos buckets `technova-app-data-*`.

## Principio do menor privilegio

O menor privilegio significa conceder somente as acoes e os recursos necessarios para cada funcao. Neste codigo, isso aparece nas actions especificas de S3, na condicao de tag para iniciar/parar/reiniciar EC2 e na separacao entre os grupos.

Usar `AmazonS3FullAccess` daria acesso muito mais amplo do que o necessario, inclusive a buckets fora do projeto e a operacoes destrutivas. As policies customizadas reduzem esse risco e deixam a intencao revisavel em Pull Requests.

## Diagrama de permissoes

```text
Juliana ─┐
Rafael  ─┼─> developers ─> s3-read + deny-destructive
Lucas   ─┘                 
Rafael ─────> platform-eng ─> ec2-s3-full (EC2 com tag Project=TechNova)

EC2 ─> instance profile ─> ec2-role ─> S3 technova-app-data-* (temporario)
```

## Comandos utilizados

```bash
terraform fmt
terraform init
terraform validate
terraform plan -out=tfplan
terraform show tfplan > terraform-plan-output.txt
terraform apply tfplan
terraform destroy
```

O `apply` e o `destroy` devem ser executados somente com uma sessao ativa do AWS Academy. Nenhuma access key e armazenada neste projeto.

## Reflexao

No Console AWS, a estrutura dependeria de muitos cliques e seria mais dificil de revisar ou recriar. Com Terraform, grupos, usuarios, policies, role e instance profile ficam versionados e podem ser avaliados antes da aplicacao com `terraform plan`.

O arquivo `laboratorio-parte2.md` orientou o uso de Spec-Driven: requisitos, design e checklist de seguranca foram revisados antes da implementacao. A versao final segue o TF da disciplina, que exige dois grupos e coloca Lucas no grupo de desenvolvedores com protecao por `Deny` explicito.