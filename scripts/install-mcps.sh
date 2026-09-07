#!/usr/bin/env bash
set -euo pipefail

region="${AWS_REGION:-}"
profile="${AWS_PROFILE:-default}"
if [[ -z "$region" ]]; then
  read -r -p 'Região AWS para a configuração local (ex.: us-east-1): ' region
fi
if [[ -z "$region" ]]; then
  echo 'Região obrigatória.' >&2
  exit 1
fi

if ! command -v uvx >/dev/null 2>&1; then
  echo 'uvx não encontrado. Instale uv antes de configurar os MCPs.' >&2
  exit 1
fi

mkdir -p generated
config="generated/mcp-config.json"
cat > "$config" <<EOF
{
  "aws-cost-management": {
    "type": "stdio",
    "command": "wsl.exe",
    "args": ["bash", "-lc", "uvx awslabs.billing-cost-management-mcp-server@latest"],
    "env": {"AWS_PROFILE": "$profile", "AWS_REGION": "$region"}
  },
  "aws-pricing": {
    "type": "stdio",
    "command": "wsl.exe",
    "args": ["bash", "-lc", "uvx awslabs.aws-pricing-mcp-server@latest"],
    "env": {"AWS_PROFILE": "$profile", "AWS_REGION": "$region"}
  }
}
EOF
chmod 600 "$config"
printf 'Configuração gerada em %s\n' "$config"
echo 'Copie somente a configuração para o cliente de IA local. Não commite este arquivo.'

