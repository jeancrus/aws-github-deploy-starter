# Validar deploy

Verifique workflow, containers, logs, readiness, migrations, health e rollback. Em falha, preserve evidências e não apague dados automaticamente.

Checklist mínimo:

1. `PRODUCTION_SSM_ENABLED` e branch corretos
2. SSH fingerprint ok
3. `deploy.sh` rodou sync + **force-recreate** + health
4. `curl` local na EC2
5. Se Pages: `/api` via proxy, sem `BACKEND_API_URL is not configured`

Classifique: código, configuração, IAM, rede, dependência ou host. Indique o próximo comando seguro (sem secrets).
