# Reflexao - Spec-Driven para IAM

## O que a IA acertou de primeira?

A estrutura proposta separa identidade, grupos, policies e role, mantendo o fluxo `grupo -> policy -> usuario` e o instance profile para o EC2.

## O que precisou de correcao?

Foi necessario alinhar o desenho ao `TF.md`: a entrega final usa dois grupos, enquanto o laboratorio apresenta um terceiro grupo de interns. Tambem foi necessario restringir as actions e recursos das policies e incluir tags padronizadas.

## O checklist de validacao pegou algum problema?

O checklist exige verificar `terraform validate`, o plano, actions especificas, `Deny` explicito, condicao de tag, trust policy do EC2, instance profile e ausencia de access keys hardcoded. O plano real ainda depende da instalacao local do Terraform e de credenciais AWS validas.

## Comparacao: se eu escrevesse manualmente, quanto tempo levaria?

A escrita inicial seria mais demorada porque envolve sintaxe HCL, JSON de policies e dependencias entre recursos. A revisao manual continua indispensavel, especialmente para confirmar o menor privilegio.

## Em quais partes eu confiei na IA e em quais eu desconfiei?

A IA foi usada para acelerar a organizacao dos arquivos e a sintaxe repetitiva. As permissoes, os ARNs, as condicoes e a diferenca entre o laboratorio e o TF foram tratados como pontos que exigem conferencia humana.

## O principio do menor privilegio foi respeitado na primeira geracao?

Ele foi aplicado na versao final por meio de actions especificas, recursos com prefixo TechNova, condicao de tag no EC2 e `Deny` para acoes destrutivas. A validacao com `terraform plan` e a revisao das policies continuam obrigatorias antes de qualquer `apply`.