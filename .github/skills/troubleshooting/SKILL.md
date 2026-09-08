# Troubleshooting

Colete evidências sem secrets: identidade AWS, região, status do agente, policy efetiva, logs e estado dos containers. Classifique a causa antes de alterar recursos.

## Ordem de diagnóstico

1. Identidade: `aws sts get-caller-identity` (local e na EC2)
2. Região e prefixo SSM corretos?
3. OIDC / environment / role ARN (Actions)
4. Instance profile + SSM Agent
5. Compose `ps` / logs (sem imprimir env)
6. Health local na EC2
7. Só então rede/SG/Pages

## Casos frequentes

### OIDC não autorizado

Conta, região, role ARN, provider, `aud`, `sub` (repo + `environment:production`), permissions `id-token: write`. Se a conta já tinha provider, o bootstrap precisa de `ExistingOidcProviderArn`.

### Fingerprint SSH incompatível

Não desative a verificação. Confirme host, leia fingerprints na instância, atualize o secret só após rotação legítima.

### Session Manager não lista a instância

Agent ativo, instance profile com `AmazonSSMManagedInstanceCore`, egress, arch da AMI. Aguarde minutos após anexar a role.

### GetParametersByPath negado

Path `/<project>/production`, região, policy do instance profile, KMS se houver CMK.

### Deploy verde mas API “velha” / 404 em rota nova

Falta `--force-recreate` no serviço app. O código no disco atualizou; o processo dentro do container não.

### Postgres / readiness

Container parado com volume → refuse. Senha SSM ≠ senha do volume → abortar e corrigir SSM (não “resetar” volume sem backup).

### Pages: `BACKEND_API_URL is not configured`

Var no projeto **Pages**, com porta e hostname; redeploy. Ver skill `cloudflare-pages-proxy`.

### Health falha após up

`docker compose ps`, logs do app (tail), migrations, DB up, porta correta. Preserve `candidate.json` para diagnóstico; não apague volumes.

## Não fazer

- Contornar fingerprint, OIDC ou SG como primeira resposta
- Logar SecureString / `candidate.json`
- `terraform destroy` ou recreate de EC2 para “testar” um 404 de rota
