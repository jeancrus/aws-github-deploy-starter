# Deploy de produção do zero: AWS + GitHub Actions

Este roteiro é genérico. Substitua valores entre `<...>`; não copie nomes, contas, IPs ou secrets de outro projeto.

## 1. Defina o contexto

Responda: qual é o repositório do backend, se existe um frontend separado, qual repositório contém a infraestrutura/deploy, branch de produção, região, orçamento mensal, disponibilidade, portas públicas, dependências e endpoint de health check.

Se você não conhece as regiões, consulte a [lista oficial de regiões da AWS](https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html). Escolha uma região próxima dos usuários e confirme a disponibilidade dos serviços necessários. Exemplos: `us-east-1` (Norte da Virgínia), `sa-east-1` (São Paulo) e `eu-west-1` (Irlanda).

Se você não conhece as regiões, consulte a [lista oficial de regiões da AWS](https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html). Escolha uma região próxima dos usuários e confirme a disponibilidade dos serviços necessários. Exemplos: `us-east-1` (Norte da Virgínia), `sa-east-1` (São Paulo) e `eu-west-1` (Irlanda).

Use o wizard local:

```bash
bash scripts/decision-wizard.sh
```

## 2. Verifique pré-requisitos

```bash
bash scripts/check-prerequisites.sh
aws sts get-caller-identity
```

O perfil deve apontar para a conta e região corretas. Nunca cole credenciais no terminal compartilhado ou em issues.

### Repositórios usados pelo setup

O repositório do backend é obrigatório: ele é a fonte do código que será clonado e executado na EC2. Informe também o frontend quando ele for separado e o repositório de infraestrutura/deploy quando os workflows ou Terraform estiverem em outro lugar. Se a infraestrutura estiver junto do backend, deixe esse último campo vazio; o wizard usará o backend como padrão.

## 3. Escolha a arquitetura pelo custo-benefício

Leia [cost-analysis.md](cost-analysis.md) e instale os MCPs com `bash scripts/install-mcps.sh`. Compare ARM64 e x86 considerando EC2, EBS, IPv4, transferência, snapshots, logs e dependências. Registre a decisão em `generated/decision-record.md` e revise a estimativa antes de provisionar.

## 4. Crie a rede e a EC2

Crie ou selecione VPC, sub-rede e route table. Configure Security Group mínimo: SSH somente de origem administrativa temporária, ou não exponha e use Session Manager; HTTP/HTTPS apenas se necessário; banco, Redis e portas internas nunca públicos.

Crie a instância com tipo, AMI, sub-rede, volume EBS criptografado e tags aprovados na etapa de custo. Use instance profile com apenas as permissões necessárias.

## 5. Prepare o runtime

Instale Docker, Compose plugin e agente SSM conforme distribuição e arquitetura da AMI. Valide `docker --version`, `docker compose version` e o serviço do SSM. Use Session Manager para a primeira conexão sempre que possível.

## 6. Prepare o repositório

Crie deploy key somente de leitura para clonar o repositório, ou use outro mecanismo aprovado. Clone em diretório explícito, configure o usuário do serviço e teste `docker compose config` sem imprimir secrets.

## 7. Configure parâmetros e secrets

Prefira SSM Parameter Store `SecureString` ou Secrets Manager. Não grave secrets no git, artefatos, logs ou imagem Docker.

## 8. Configure IAM e OIDC

Crie OIDC provider para `token.actions.githubusercontent.com` e role com trust policy restrita à audiência `sts.amazonaws.com`, repositório exato e branch/environment exato. Permita apenas ações AWS usadas por `plan` e `apply`. Consulte `templates/github-actions/`.

## 9. Configure o GitHub Environment

Crie um environment protegido. Use variables para região, role ARN, state bucket e flags não sensíveis; secrets para chave SSH, fingerprint, host, usuário e integrações. O conteúdo da chave privada deve manter as linhas `BEGIN` e `END` e nunca aparecer em logs.

## 10. Rode plan e apply

Abra branch e PR, rode validação e `terraform plan`, revise recursos, região, conta e custo, e somente então execute `apply` aprovado. Confirme outputs sem expor valores sensíveis.

## 11. Faça o primeiro deploy

O deploy deve fazer checkout fast-forward, carregar configuração, construir imagens, subir dependências, aguardar readiness e validar health check. Em falha, mantenha o candidato para diagnóstico e não faça rollback de banco automaticamente sem estratégia aprovada.

## 12. Valide e opere

Teste URL de health, logs, banco/Redis, migrations, domínio e TLS. Registre o fingerprint SSH do host atual e atualize-o somente após confirmar rotação legítima. Configure budget e revise recursos ociosos periodicamente.
