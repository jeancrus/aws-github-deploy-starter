#!/usr/bin/env bash
set -euo pipefail

mkdir -p generated
read -r -p 'Nome do projeto: ' project
read -r -p 'Região AWS: ' region
read -r -p 'Orçamento mensal máximo (moeda): ' budget
read -r -p 'Repositório GitHub (owner/name): ' repository
read -r -p 'Branch de produção: ' branch
read -r -p 'Precisa de alta disponibilidade desde o início? [s/N] ' ha
read -r -p 'Health check esperado (URL ou comando): ' health

cat > generated/decision-record.md <<EOF
# Registro inicial de decisão

- Projeto: $project
- Região: $region
- Orçamento mensal: $budget
- Repositório: $repository
- Branch de produção: $branch
- Alta disponibilidade inicial: ${ha:-N}
- Health check: $health
- Data: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Próximas decisões

- [ ] Consultar AWS Pricing MCP.
- [ ] Consultar AWS Cost Management MCP.
- [ ] Comparar ARM64 e x86.
- [ ] Incluir EBS, IPv4, transferência, logs e dependências.
- [ ] Revisar estimativa com o responsável da conta.
- [ ] Confirmar tipo de EC2 antes de provisionar.

EOF
chmod 600 generated/decision-record.md
printf 'Registro criado em generated/decision-record.md\n'
echo 'Nenhum recurso AWS foi criado.'

