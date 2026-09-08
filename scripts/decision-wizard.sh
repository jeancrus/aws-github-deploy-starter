#!/usr/bin/env bash
set -euo pipefail

mkdir -p generated
read -r -p 'Nome do projeto: ' project
cat <<'REGION_HELP'

A região AWS é a localização física onde os recursos serão criados.
Escolha uma região próxima dos usuários e confirme se todos os serviços da aplicação estão disponíveis nela.

Lista oficial de regiões:
https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html

Exemplos comuns:
  us-east-1      Estados Unidos (Norte da Virgínia)
  us-east-2      Estados Unidos (Ohio)
  sa-east-1      América do Sul (São Paulo)
  eu-west-1      Europa (Irlanda)
  ap-southeast-1 Ásia-Pacífico (Singapura)
REGION_HELP

if command -v aws >/dev/null 2>&1; then
  echo 'Regiões visíveis na conta AWS atual (se a sessão estiver autenticada):'
  if ! aws ec2 describe-regions --all-regions --query 'Regions[].RegionName' --output text 2>/dev/null | tr '\t' '\n' | sort | sed 's/^/  /'; then
    echo '  Não foi possível consultar a conta agora; use a lista oficial acima.'
  fi
fi

read -r -p 'Região AWS escolhida (ex.: us-east-1): ' region
while [[ -z "$region" ]]; do
  echo 'A região é obrigatória. Consulte o link acima e informe um identificador como us-east-1.'
  read -r -p 'Região AWS escolhida: ' region
done
read -r -p 'Orçamento mensal máximo (moeda): ' budget
read -r -p 'Repositório do backend (owner/name): ' backend_repository
while [[ -z "$backend_repository" ]]; do
  echo 'O repositório do backend é obrigatório porque ele será implantado na EC2.'
  read -r -p 'Repositório do backend (owner/name): ' backend_repository
done
read -r -p 'Repositório do frontend (owner/name, opcional): ' frontend_repository
read -r -p 'Repositório de infraestrutura/deploy (opcional; Enter = backend): ' deployment_repository
deployment_repository="${deployment_repository:-$backend_repository}"
read -r -p 'Branch de produção: ' branch
read -r -p 'Precisa de alta disponibilidade desde o início? [s/N] ' ha
read -r -p 'Porta da API na EC2 (ex.: 3000): ' api_port
while [[ -z "$api_port" ]]; do
  echo 'A porta da API é obrigatória para health check e para BACKEND_API_URL no Pages.'
  read -r -p 'Porta da API na EC2: ' api_port
done
read -r -p 'Health check esperado (URL ou comando): ' health
read -r -p 'Frontend em Cloudflare Pages com proxy /api? [s/N] ' pages

cat > generated/decision-record.md <<EOF
# Registro inicial de decisão

- Projeto: $project
- Região: $region
- Orçamento mensal: $budget
- Repositório do backend: $backend_repository
- Repositório do frontend: ${frontend_repository:-não informado}
- Repositório de infraestrutura/deploy: $deployment_repository
- Branch de produção: $branch
- Alta disponibilidade inicial: ${ha:-N}
- Porta da API: $api_port
- Health check: $health
- Cloudflare Pages + proxy: ${pages:-N}
- Data: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Arquitetura alvo (Lean MVP)

- EC2 + Docker Compose + SSM Parameter Store
- GitHub Actions OIDC → parâmetros; SSH → deploy.sh (--force-recreate)
- Fonte de verdade: SSM (não .env.production na VM)

## Próximas decisões

- [ ] Consultar AWS Pricing MCP.
- [ ] Consultar AWS Cost Management MCP.
- [ ] Comparar ARM64 (t4g.*) e x86.
- [ ] Incluir EBS, IPv4, transferência, logs e dependências.
- [ ] Revisar estimativa com o responsável da conta.
- [ ] Confirmar tipo de EC2 antes de provisionar.
- [ ] CloudFormation bootstrap (OIDC/SSM/state).
- [ ] Environment GitHub production + primeiro plan/apply SSM.
- [ ] Deploy com PRODUCTION_SSM_ENABLED=true.
- [ ] Se Pages: BACKEND_API_URL=http://<hostname>:$api_port no projeto Pages.

EOF
chmod 600 generated/decision-record.md
printf 'Registro criado em generated/decision-record.md\n'
echo 'Nenhum recurso AWS foi criado.'
echo 'Próximo: docs/getting-started.md ou skill lean-mvp-aws-deploy.'
