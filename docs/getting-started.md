# Deploy Lean MVP do zero: AWS + GitHub Actions

Roteiro genérico alinhado ao padrão que funciona em produção: **EC2 barata + Docker Compose + SSM Parameter Store + GitHub OIDC + deploy SSH**, com **Cloudflare Pages** opcional para SPA.

Substitua `<...>`. Não copie host, conta, IP ou secrets de outro projeto.

## Visão rápida

```text
1. Decisões + custo
2. EC2 + Docker + swap
3. CloudFormation bootstrap (OIDC / S3 state / EC2 profile)
4. Environment GitHub production
5. Terraform → SSM (plan → apply)
6. Deploy (git pull + deploy.sh com --force-recreate)
7. (Opcional) Pages + proxy /api
```

Arquitetura: [architecture.md](architecture.md).  
Agente Cursor: skill `.cursor/skills/lean-mvp-aws-deploy/`.  
Templates: `templates/`.

## 1. Defina o contexto

Responda: repositório do backend (obrigatório), frontend separado (opcional), repo de infra (opcional), branch de produção, região, orçamento, disponibilidade, portas públicas, dependências e health check.

Regiões: [lista oficial AWS](https://docs.aws.amazon.com/global-infrastructure/regions_az/index.html). Exemplos: `us-east-1`, `sa-east-1`, `eu-west-1`.

```bash
bash scripts/decision-wizard.sh
```

## 2. Pré-requisitos

```bash
bash scripts/check-prerequisites.sh
aws sts get-caller-identity
```

Nunca cole access keys no chat, issues ou logs.

## 3. Custo-benefício

Leia [cost-analysis.md](cost-analysis.md). Preferência Lean: **Graviton `t4g.micro`**, EBS pequeno, sem ALB/RDS/NAT. Ordem de grandeza típica: ~US$ 8–12/mês + Pages free. Registre a escolha em `generated/decision-record.md` e peça aprovação humana antes de criar recursos.

## 4. Máquina (EC2)

Crie VPC/sub-rede/SG mínimos ou use Terraform lean em `templates/terraform/`.

- SSH só de CIDR admin `/32`, ou use Session Manager sem abrir 22
- Publique a porta da API só se o front/proxy precisar
- **Nunca** exponha 5432/Redis
- EIP ajuda a manter DNS `ec2-….amazonaws.com` estável para Pages

Na primeira conexão: `templates/scripts/bootstrap-ec2.sh` (swap + Docker). Confirme arch (`aarch64` vs `x86_64`).

## 5. Bootstrap de config (CloudFormation, uma vez)

1. Abra `templates/cloudformation/bootstrap.yml`
2. Crie a stack na região escolhida
3. Parâmetros: `ProjectSlug`, `GitHubRepository`, `GitHubRepositoryImmutableSubject`, `ExistingOidcProviderArn` (vazio **ou** ARN se a conta já tiver OIDC)
4. Copie Outputs: `StateBucketName`, `ConfigRunnerRoleArn`, `Ec2InstanceProfileName`

Anexe o instance profile à EC2 → Security → Modify IAM role.

Instale SSM Agent + AWS CLI na arch correta. Crie:

```bash
sudo install -d -m 700 -o ubuntu -g ubuntu /opt/<PROJECT>-runtime
sudo install -d -m 0755 -o ubuntu -g ubuntu /opt/<PROJECT>-api
```

Clone com deploy key somente leitura na branch de produção (working tree limpa).

## 6. Environment GitHub `production`

**Variables:** `AWS_REGION`, `TF_STATE_BUCKET`, `AWS_CONFIG_ROLE_ARN`, `PRODUCTION_SSM_ENABLED=false`, `PRODUCTION_CONFIG_JSON={}`

**Secrets:** `PRODUCTION_SECRETS_JSON`, `EC2_HOST` (hostname DNS, não IP cru), `EC2_SSH_KEY`, `EC2_HOST_FINGERPRINT`, opcional `EC2_USER`

Teste OIDC: copie `templates/github-actions/identity.yml` e rode o workflow.

## 7. Código de produção no backend

Copie e adapte:

| Origem no starter | Destino no backend |
| --- | --- |
| `templates/scripts/production/*` | `scripts/production/` |
| `templates/docker-compose.prod.yml` | `docker-compose.prod.yml` |
| `templates/github-actions/deploy.yml` | `.github/workflows/deploy.yml` |
| `templates/github-actions/production-config.yml` | `.github/workflows/production-config.yml` |
| `templates/terraform/production-config.README.md` | `infra/production-config/` (implementar `main.tf`) |
| `templates/cloudformation/bootstrap.yml` | `infra/production-config/bootstrap.yml` |

Substitua todos os `<PLACEHOLDERS>`.

## 8. Primeiro apply de parâmetros + deploy

1. Merge na branch de produção
2. Actions → **Production parameters** → `plan` → revise → `apply`
3. Na EC2, liste nomes/tipos SSM **sem** descriptografar em logs
4. `PRODUCTION_SSM_ENABLED=true`
5. **Deploy to Production** (push ou `workflow_dispatch`)
6. Health: `curl` em `http://127.0.0.1:<PORT>/<health>` na EC2

O `deploy.sh` **precisa** de `--force-recreate` no serviço da app. Sem isso, código novo no disco não entra no processo em memória.

## 9. Frontend (opcional)

Siga [cloudflare-pages.md](cloudflare-pages.md) e a skill `cloudflare-pages-proxy`.

Pontos críticos: projeto **Pages**; `BACKEND_API_URL` com hostname + porta; redeploy após mudar a var; `CORS_ORIGIN` HTTPS alinhado.

## 10. Operação contínua

- Parâmetros: workflow manual `plan`/`apply`
- Código: push na branch de produção (com flag ligada)
- Ops: Session Manager; budgets AWS; revise recursos ociosos
- Troubleshooting: [troubleshooting.md](troubleshooting.md)

## Segurança

Nunca coloque `.pem`, access keys ou valores de produção neste starter. Leia [security.md](security.md).
