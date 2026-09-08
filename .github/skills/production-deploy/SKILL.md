# Production deploy

Conduza o rollout do app na EC2 com o padrão Arenex/SSM. Não registre secrets. Em falha, preserve o candidato e não faça rollback automático de volume/banco.

## Quando usar

Usuário pediu deploy de produção, primeiro rollout, `deploy.sh`, readiness, ou “subir na EC2 via GitHub Actions”.

## Pré-condições

- [ ] CloudFormation bootstrap aplicado; instance profile anexado
- [ ] SSM já tem parâmetros (`plan`/`apply` ok)
- [ ] `PRODUCTION_SSM_ENABLED=true` no Environment `production`
- [ ] Secrets `EC2_HOST`, `EC2_SSH_KEY`, `EC2_HOST_FINGERPRINT` preenchidos
- [ ] `EC2_HOST` é **hostname** DNS (não IP) se houver Cloudflare Pages
- [ ] Templates adaptados em `scripts/production/` e `.github/workflows/deploy.yml`

## Sequência na VM (obrigatória)

```text
cd <APP_DIR>
git pull --ff-only origin <PRODUCTION_BRANCH>
bash scripts/production/deploy.sh
```

O `deploy.sh` (ver `templates/scripts/production/deploy.sh`) deve:

1. Lock em `<RUNTIME_DIR>/deploy.lock`
2. `sync_config.py` → `<RUNTIME_DIR>/candidate.json` (mode `0600`, fora do git)
3. `docker compose … config` (validar override)
4. Guardas de DB (se Postgres com volume): senha bate / container parado → abortar
5. `build` do serviço app
6. **`up -d --force-recreate --no-deps <app>`** (+ sidecars de métricas se houver)
7. `up -d` do restante
8. Loop de health em `<HEALTH_URL>`
9. Sucesso → `candidate` vira `current`; falha → candidato permanece para diagnóstico

## Workflow GitHub

Use `templates/github-actions/deploy.yml`:

- Gate: só branch de produção + `PRODUCTION_SSM_ENABLED == true`
- SSH com fingerprint; nunca desligar verificação
- Script remoto: branch correta, working tree limpa, `pull --ff-only`, `deploy.sh`
- Concurrency group compartilhado com o workflow de parâmetros; `cancel-in-progress: false`

## Validação pós-deploy

```bash
curl -fsS <HEALTH_URL>
docker compose --project-name <PROJECT> -f docker-compose.prod.yml ps
```

Confirme que uma mudança de código (ex.: rota nova) entra no ar após o recreate — sintoma de bug clássico: 404 em rota já no disco porque o processo Node antigo ficou vivo.

## Não fazer

- `up -d` sem recreate quando o app usa bind-mount + processo long-lived
- Logar `candidate.json`, env Compose ou `SecureString`
- Rollback automático de Postgres/volume
- Deploy com tree dirty ou branch errada
