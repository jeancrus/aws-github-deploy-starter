# Troubleshooting

Colete evidências **sem** imprimir secrets. Classifique a causa antes de mudar SG, OIDC ou volumes.

## OIDC não autorizado

Confira conta, região, role ARN, provider, audiência `sts.amazonaws.com`, repositório e `environment:production` no `sub`. Workflow precisa de `id-token: write`. Se a conta já tinha provider, o bootstrap deve usar `ExistingOidcProviderArn`.

## Fingerprint SSH incompatível

Não desative a verificação. Confirme o host, leia os fingerprints na instância e atualize o secret só após rotação legítima.

## Session Manager não lista a instância

Agent SSM ativo, instance profile com `AmazonSSMManagedInstanceCore`, egress e arch da AMI. Aguarde após anexar a role.

## GetParametersByPath negado

Região, path `/<project>/production`, policy do instance profile e (se houver) KMS.

## Deploy OK mas API antiga / 404 em rota nova

Falta `--force-recreate` no serviço app no `deploy.sh`. Código no disco ≠ processo em memória.

## Readiness falha

`docker compose ps`, logs (tail), migrations, DB, health URL. Preserve o `candidate.json`; não apague volumes automaticamente.

## Postgres / senha

SSM SecureString deve bater com a senha já usada no volume. Container postgres parado com volume existente → recusar deploy até investigação.

## Pages: `BACKEND_API_URL is not configured`

Variável no projeto **Pages**, hostname + porta, redeploy. Ver [cloudflare-pages.md](cloudflare-pages.md).

## Pages: network error / CORS

IP cru, porta ausente, ou `CORS_ORIGIN` sem o HTTPS do Pages.

## Checklist rápido na EC2

```bash
aws sts get-caller-identity
aws ssm get-parameters-by-path --path /<project>/production --recursive \
  --query 'Parameters[].{Name:Name,Type:Type}' --output table
docker compose --project-name <project> -f docker-compose.prod.yml ps
curl -fsS http://127.0.0.1:<port>/<health>
```
