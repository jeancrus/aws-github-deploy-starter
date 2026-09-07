#!/usr/bin/env bash
set -euo pipefail

missing=0
full_setup_missing=0
for command in git curl unzip; do
  if command -v "$command" >/dev/null 2>&1; then
    printf 'OK   %s\n' "$command"
  else
    printf 'MISS %s\n' "$command"
    missing=1
  fi
done

if command -v aws >/dev/null 2>&1; then
  printf 'OK   aws (AWS CLI)\n'
else
  printf 'MISS aws (AWS CLI) — necessário para o setup completo\n'
  echo '     Instalação: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html'
  echo '     Depois valide com: aws sts get-caller-identity'
  full_setup_missing=1
fi

if command -v uvx >/dev/null 2>&1; then
  printf 'OK   uvx (MCPs AWS)\n'
else
  printf 'MISS uvx — necessário para instalar os MCPs de pricing e custos\n'
  echo '     Instalação: https://docs.astral.sh/uv/getting-started/installation/'
  full_setup_missing=1
fi

if command -v gh >/dev/null 2>&1; then
  printf 'OK   gh (GitHub CLI, opcional)\n'
else
  printf 'INFO gh não encontrado (opcional; use a interface web se preferir)\n'
  echo '     Instalação: https://cli.github.com/'
fi

if [[ "$missing" -ne 0 ]]; then
  echo 'Instale os comandos obrigatórios e execute novamente.' >&2
  exit 1
fi

if [[ "$full_setup_missing" -ne 0 ]]; then
  echo 'Instale os itens marcados como MISS antes de continuar com o setup completo.' >&2
  exit 1
fi

echo 'Todos os pré-requisitos do setup completo estão disponíveis.'
