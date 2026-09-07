#!/usr/bin/env bash
set -euo pipefail

missing=0
for command in git curl unzip; do
  if command -v "$command" >/dev/null 2>&1; then
    printf 'OK   %s\n' "$command"
  else
    printf 'MISS %s\n' "$command"
    missing=1
  fi
done

for optional in aws uvx gh; do
  if command -v "$optional" >/dev/null 2>&1; then
    printf 'OK   %s (opcional/recomendado)\n' "$optional"
  else
    printf 'INFO %s não encontrado\n' "$optional"
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo 'Instale os comandos obrigatórios e execute novamente.' >&2
  exit 1
fi

