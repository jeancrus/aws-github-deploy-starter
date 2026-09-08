#!/usr/bin/env bash
# Production deploy on EC2: checkout already updated + SSM → private Compose override.
# Copy into your backend repo as scripts/production/deploy.sh and replace placeholders.
set -euo pipefail
umask 077

APP_DIR="${APP_DIR:-/opt/<PROJECT>-api}"
RUNTIME_DIR="${RUNTIME_DIR:-/opt/<PROJECT>-runtime}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"
PROJECT_NAME="${PROJECT_NAME:-<PROJECT>}"
APP_SERVICE="${APP_SERVICE:-api}"
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:3000/health}"

cd "$APP_DIR"
: "${AWS_REGION:?Set AWS_REGION}"
test -f "$COMPOSE_FILE"

install -d -m 700 "$RUNTIME_DIR"
test -w "$RUNTIME_DIR"
exec 9>"$RUNTIME_DIR/deploy.lock"
flock -n 9 || {
  echo 'Another deployment is running'
  exit 1
}

python3 scripts/production/sync_config.py --region "$AWS_REGION" --output "$RUNTIME_DIR/candidate.json"

compose=(docker compose --project-name "$PROJECT_NAME" --env-file /dev/null -f "$COMPOSE_FILE")
candidate=("${compose[@]}" -f "$RUNTIME_DIR/candidate.json")
"${candidate[@]}" config --quiet

# Build before replacing a running app. Do not prune: preserve rollback material.
"${candidate[@]}" build "$APP_SERVICE"
if test -f "$RUNTIME_DIR/current.json"; then
  cp "$RUNTIME_DIR/current.json" "$RUNTIME_DIR/previous.json"
fi

# Force recreate so bind-mounted source + long-lived process pick up the new revision.
# Without this, `up -d` leaves a healthy container running the previous process.
"${candidate[@]}" up -d --force-recreate --no-deps "$APP_SERVICE"
"${candidate[@]}" up -d

healthy=false
for _ in $(seq 1 90); do
  if curl --fail --silent --max-time 5 "$HEALTH_URL" >/dev/null; then
    healthy=true
    break
  fi
  sleep 5
done

if [[ "$healthy" != true ]]; then
  echo 'Readiness failed. Candidate retained for diagnosis; no automatic database rollback.'
  "${candidate[@]}" ps || true
  "${candidate[@]}" logs --tail=80 "$APP_SERVICE" || true
  exit 1
fi

mv "$RUNTIME_DIR/candidate.json" "$RUNTIME_DIR/current.json"
git rev-parse HEAD >"$RUNTIME_DIR/current-revision"
echo "Deployment ready (revision $(cat "$RUNTIME_DIR/current-revision"))."
echo "Check: curl -s $HEALTH_URL"
