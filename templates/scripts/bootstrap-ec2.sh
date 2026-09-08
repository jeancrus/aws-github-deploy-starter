#!/usr/bin/env bash
# First-boot helpers for a Lean MVP EC2 (Docker + swap). Run as root or with sudo.
# Adapt PROJECT dirs before use. Does not install AWS credentials — use instance profile.
set -euo pipefail

PROJECT="${PROJECT:-<PROJECT>}"
APP_DIR="${APP_DIR:-/opt/${PROJECT}-api}"
RUNTIME_DIR="${RUNTIME_DIR:-/opt/${PROJECT}-runtime}"
SWAP_MB="${SWAP_MB:-2048}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo 'Run as root (sudo).'
  exit 1
fi

echo "Architecture: $(uname -m)"

if ! swapon --show | grep -q .; then
  fallocate -l "${SWAP_MB}M" /swapfile || dd if=/dev/zero of=/swapfile bs=1M count="$SWAP_MB"
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >>/etc/fstab
  echo "Swap ${SWAP_MB}M enabled."
else
  echo 'Swap already present.'
fi

if ! command -v docker >/dev/null 2>&1; then
  apt-get update
  apt-get install -y ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  # shellcheck disable=SC1091
  . /etc/os-release
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
    >/etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

docker --version
docker compose version

install -d -m 0755 "$APP_DIR"
install -d -m 0700 "$RUNTIME_DIR"
echo "Prepared $APP_DIR and $RUNTIME_DIR"
echo 'Next: attach instance profile, install SSM Agent + AWS CLI, clone the repo with a read-only deploy key.'
