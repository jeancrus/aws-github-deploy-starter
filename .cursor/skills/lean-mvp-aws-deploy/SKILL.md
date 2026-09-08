---
name: lean-mvp-aws-deploy
description: >-
  Step-by-step Lean MVP production on AWS for beginners: cheap EC2, Docker
  Compose, SSM Parameter Store, GitHub Actions OIDC, SSH deploy with
  force-recreate, optional Cloudflare Pages proxy. Guides one gate at a time
  with console links and copy-paste commands. Use when the user wants to put
  an app online on AWS, bootstrap production, configure OIDC/SSM, or follow
  this starter's Arenex/SSM pattern.
---

# Lean MVP AWS + GitHub Deploy (passo a passo)

Conduza o usuário **uma etapa por vez**. Em cada etapa: explique o porquê em 1–2 frases, dê **links clicáveis**, blocos **copiar/colar**, o que ele deve ver, e **pare** até ele confirmar (cole o output ou diga “feito”).

Não pule etapas. Não rode `apply`/create stack/deploy cobrado sem confirmação explícita. Nunca peça ou logue secrets (só oriente onde colar no console).

Placeholders (substitua pelos valores do `generated/decision-record.md`):

| Token | Significado |
| --- | --- |
| `<REGION>` | ex. `sa-east-1` |
| `<PROJECT>` | slug curto |
| `<OWNER/REPO>` | backend `owner/name` |
| `<BRANCH>` | branch de produção |
| `<API_PORT>` | ex. `3000` |
| `<HEALTH_PATH>` | ex. `/api/v1/health` |

Detalhes/pitfalls: [reference.md](reference.md). Arquitetura: [docs/architecture.md](../../../docs/architecture.md).

---

## Como o agente deve se comportar

1. Cole o **painel de progresso** (abaixo) e atualize os `[x]` conforme o usuário avança.
2. Faça **uma pergunta por vez** na Etapa 0.
3. Em cada etapa seguinte envie neste formato:
   - **Objetivo**
   - **Links** (URLs completas `https://…`)
   - **Copiar/colar** (comandos ou valores)
   - **O que você deve ver**
   - **Me responda com:** (o que colar de volta)
4. Só avance quando o gate da etapa estiver ok.
5. Se falhar → skill `troubleshooting`; não “contornar” fingerprint/OIDC/SG.

```text
Lean MVP — progresso
- [ ] 0. Descoberta + decision-record
- [ ] 1. Pré-requisitos locais + identidade AWS
- [ ] 2. Custo aprovado (tipo EC2)
- [ ] 3. Key pair + Security Group + EC2 + EIP
- [ ] 4. Bootstrap na VM (swap, Docker)
- [ ] 5. CloudFormation (OIDC/SSM/state)
- [ ] 6. Instance profile + SSM Agent + AWS CLI
- [ ] 7. Dirs + deploy key + clone
- [ ] 8. Copiar templates para o backend + push
- [ ] 9. GitHub Environment (vars/secrets)
- [ ] 10. Teste OIDC (identity workflow)
- [ ] 11. SSM plan → apply
- [ ] 12. Flag PRODUCTION_SSM_ENABLED + primeiro deploy
- [ ] 13. Health check na EC2
- [ ] 14. (Opcional) Cloudflare Pages + proxy
- [ ] 15. Critérios de sucesso finais
```

---

## Etapa 0 — Descoberta

**Objetivo:** registrar premissas sem criar recursos.

**Links:**
- Regiões AWS: https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html

**Copiar/colar** (no clone deste starter):

```bash
cd aws-github-deploy-starter
bash scripts/check-prerequisites.sh
bash scripts/decision-wizard.sh
```

Pergunte na ordem (uma por vez): nome/slug do projeto → `owner/name` do backend → frontend separado? → região → orçamento → HA? (Lean = não) → porta da API → health path → Pages?

**Me responda com:** conteúdo resumido de `generated/decision-record.md` (sem secrets).

---

## Etapa 1 — Pré-requisitos + identidade

**Objetivo:** confirmar CLI e conta certas.

**Links:**
- Guia AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Console (conta atual): https://console.aws.amazon.com/

**Copiar/colar:**

```bash
aws sts get-caller-identity
aws configure get region
```

**O que você deve ver:** `Account`, `Arn`, `UserId` da conta de destino.

**Me responda com:** `Account` + região (mascare o resto se quiser).

---

## Etapa 2 — Custo (gate humano)

**Objetivo:** escolher tipo de instância antes de pagar.

**Links:**
- Calculadora AWS: https://calculator.aws/
- EC2 On-Demand: https://aws.amazon.com/ec2/pricing/on-demand/
- Doc de custo do starter: `docs/cost-analysis.md`

Preferência Lean: **`t4g.micro`** (Graviton) + ~8–20 GB EBS. Sem ALB/RDS/NAT.

**Me responda com:** “aprovado: `<instance-type>` em `<REGION>`” (ou peça outra opção).

**Pare** até aprovação explícita.

---

## Etapa 3 — Key pair, SG, EC2, EIP

**Objetivo:** criar a máquina. **Só após “pode criar”.**

**Links** (troque `<REGION>`):
- Key pairs: `https://console.aws.amazon.com/ec2/home?region=<REGION>#KeyPairs:`
- Security Groups: `https://console.aws.amazon.com/ec2/home?region=<REGION>#SecurityGroups:`
- Launch instance: `https://console.aws.amazon.com/ec2/home?region=<REGION>#LaunchInstances:`
- Elastic IPs: `https://console.aws.amazon.com/ec2/home?region=<REGION>#Addresses:`
- AMI Ubuntu: https://cloud-images.ubuntu.com/locator/ec2/ (filtre `arm64` se Graviton)

**SG mínimo (copiar mentalmente no console):**
- Inbound SSH `22` ← seu IP `/32` (temporário) **ou** omita e use só Session Manager depois
- Inbound TCP `<API_PORT>` ← `0.0.0.0/0` (só se Pages/proxy for acessar a API)
- **Não** abra `5432`

**Launch:** Ubuntu arm64, tipo aprovado, SG acima, 1× EBS gp3 pequeno, baixe/guarde o `.pem` **fora do git**.

Associe um **Elastic IP** e anote:
- Public IPv4 DNS: `ec2-….compute.amazonaws.com` ← use **sempre** este hostname (nunca IP cru no Pages)

**Me responda com:** Instance ID + Public DNS (sem colar a chave `.pem`).

---

## Etapa 4 — Bootstrap na VM (swap + Docker)

**Objetivo:** runtime mínimo.

**Links:**
- Conectar por SSH (console): `https://console.aws.amazon.com/ec2/home?region=<REGION>#Instances:` → Connect
- Session Manager (depois da role): `https://<REGION>.console.aws.amazon.com/systems-manager/session-manager?region=<REGION>`

**Copiar/colar** (SSH com a key local):

```bash
chmod 400 /caminho/para/<KEY>.pem
ssh -i /caminho/para/<KEY>.pem ubuntu@<PUBLIC_DNS>
```

Na VM, copie o script do starter ou rode o equivalente:

```bash
# No seu PC (exemplo): enviar o template
scp -i /caminho/para/<KEY>.pem \
  templates/scripts/bootstrap-ec2.sh \
  ubuntu@<PUBLIC_DNS>:~/bootstrap-ec2.sh

# Na EC2
export PROJECT=<PROJECT>
sudo bash ~/bootstrap-ec2.sh
docker --version && docker compose version
```

**Me responda com:** saída de `docker compose version` + `free -h` (swap).

---

## Etapa 5 — CloudFormation bootstrap (OIDC + state + profile)

**Objetivo:** IAM/OIDC/S3 **sem** recriar a EC2.

**Links:**
- Create stack (upload): `https://console.aws.amazon.com/cloudformation/home?region=<REGION>#/stacks/create/template`
- OIDC providers (ver se já existe): `https://console.aws.amazon.com/iam/home#/identity_providers`

**Arquivo:** `templates/cloudformation/bootstrap.yml`

**Parâmetros (copiar no wizard CFN):**
- `ProjectSlug` = `<PROJECT>`
- `GitHubRepository` = `<OWNER/REPO>`
- `GitHubRepositoryImmutableSubject` = subject imutável do repo (GitHub → Settings do repo / docs OIDC; formato `owner@id/repo@id`)
- `ExistingOidcProviderArn` = vazio **ou** ARN se já existir `token.actions.githubusercontent.com`

**Após CREATE_COMPLETE, copie Outputs:**
- `StateBucketName`
- `ConfigRunnerRoleArn`
- `Ec2InstanceProfileName`
- `SsmPrefix`

**Me responda com:** os quatro outputs (ARNs/nomes ok; não há secret aqui).

---

## Etapa 6 — Instance profile + SSM Agent + AWS CLI

**Objetivo:** EC2 ler SSM + Session Manager.

**Links:**
- Modify IAM role: Instances → selecione → Actions → Security → Modify IAM role  
  `https://console.aws.amazon.com/ec2/home?region=<REGION>#Instances:`
- Session Manager: `https://<REGION>.console.aws.amazon.com/systems-manager/session-manager?region=<REGION>`

**Copiar/colar na EC2 (Ubuntu):**

```bash
sudo snap install amazon-ssm-agent --classic
sudo snap start amazon-ssm-agent
sudo snap services amazon-ssm-agent

uname -m   # aarch64 ou x86_64
sudo apt-get update
sudo apt-get install -y curl unzip python3 util-linux
cd /tmp
# Graviton:
curl -fL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o awscliv2.zip
# x86_64: use awscli-exe-linux-x86_64.zip
unzip -q awscliv2.zip
sudo ./aws/install --update
aws sts get-caller-identity
```

**Me responda com:** `snap services` (agent active) + Account do `get-caller-identity` na EC2.

---

## Etapa 7 — Diretórios, deploy key, clone

**Objetivo:** código RO em `/opt/<PROJECT>-api`.

**Links:**
- Deploy keys do backend: `https://github.com/<OWNER/REPO>/settings/keys`
- Novo deploy key: `https://github.com/<OWNER/REPO>/settings/keys/new` (read-only)

**Copiar/colar na EC2:**

```bash
sudo install -d -m 0755 -o ubuntu -g ubuntu /opt/<PROJECT>-api
sudo install -d -m 700 -o ubuntu -g ubuntu /opt/<PROJECT>-runtime

# Gere deploy key só nesta VM (não reutilize a key de SSH admin)
ssh-keygen -t ed25519 -f ~/.ssh/<PROJECT>_deploy -N ''
cat ~/.ssh/<PROJECT>_deploy.pub
# → cole em GitHub Deploy keys (Allow write access = OFF)
```

`~/.ssh/config` (exemplo):

```text
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/<PROJECT>_deploy
  IdentitiesOnly yes
```

```bash
git clone git@github.com:<OWNER/REPO>.git /opt/<PROJECT>-api
cd /opt/<PROJECT>-api
git checkout <BRANCH>
git status
```

**Me responda com:** `git rev-parse --short HEAD` e `git status -sb` (tree limpa).

---

## Etapa 8 — Templates no backend + push

**Objetivo:** código de produção versionado no repo do backend.

**Copiar do starter → backend:**

| Starter | Destino |
| --- | --- |
| `templates/scripts/production/*` | `scripts/production/` |
| `templates/scripts/bootstrap-ec2.sh` | `scripts/bootstrap-ec2.sh` |
| `templates/docker-compose.prod.yml` | `docker-compose.prod.yml` |
| `templates/cloudformation/bootstrap.yml` | `infra/production-config/bootstrap.yml` |
| `templates/terraform/production-config.README.md` | base de `infra/production-config/` |
| `templates/github-actions/deploy.yml` | `.github/workflows/deploy.yml` |
| `templates/github-actions/production-config.yml` | `.github/workflows/production-config.yml` |
| `templates/github-actions/identity.yml` | `.github/workflows/identity.yml` |

Substitua **todos** os `<PLACEHOLDERS>`. Implemente `infra/production-config/main.tf` (SSM String/SecureString). Abra PR, merge em `<BRANCH>`.

Na EC2 depois do merge:

```bash
cd /opt/<PROJECT>-api
git pull --ff-only origin <BRANCH>
```

**Me responda com:** URL do PR/merge + confirmação dos placeholders trocados.

---

## Etapa 9 — GitHub Environment `production`

**Objetivo:** vars/secrets sem expor valores no chat.

**Links:**
- Environments: `https://github.com/<OWNER/REPO>/settings/environments`
- Criar/editar `production`: `https://github.com/<OWNER/REPO>/settings/environments`

**Variables (copie os nomes):**

```text
AWS_REGION=<REGION>
TF_STATE_BUCKET=<StateBucketName>
AWS_CONFIG_ROLE_ARN=<ConfigRunnerRoleArn>
PRODUCTION_SSM_ENABLED=false
PRODUCTION_CONFIG_JSON={}
```

**Secrets (cole só no GitHub, não no chat):**

```text
PRODUCTION_SECRETS_JSON   → JSON com senhas/JWT (SecureString)
EC2_HOST                  → Public DNS (ec2-….amazonaws.com) SEM http://
EC2_SSH_KEY               → conteúdo completo do .pem (BEGIN/END)
EC2_HOST_FINGERPRINT      → veja comando abaixo
EC2_USER                  → ubuntu (opcional)
```

**Fingerprint (no seu PC):**

```bash
ssh-keyscan -t ed25519,rsa <PUBLIC_DNS> 2>/dev/null | ssh-keygen -lf -
```

**Me responda com:** “vars criadas” + “secrets criados” (sem valores) + fingerprint algorithm/bits (ok).

---

## Etapa 10 — Teste OIDC

**Objetivo:** Actions assume a role antes de escrever SSM.

**Links:**
- Actions: `https://github.com/<OWNER/REPO>/actions`
- Workflow Identity (após push do `identity.yml`): `https://github.com/<OWNER/REPO>/actions/workflows/identity.yml`

**O que você deve ver:** job verde + `aws sts get-caller-identity` com o Account esperado.

**Me responda com:** link do run OK (ou erro completo sem secrets).

---

## Etapa 11 — SSM `plan` → `apply`

**Objetivo:** popular `/<PROJECT>/production/*`.

**Links:**
- Workflow Production parameters: `https://github.com/<OWNER/REPO>/actions/workflows/production-config.yml`
- SSM Parameter Store: `https://console.aws.amazon.com/systems-manager/parameters/?region=<REGION>&tab=Table`

1. `workflow_dispatch` → operation **`plan`** → revise o plano.
2. Confirme com o usuário → **`apply`**.
3. Na EC2 (sem descriptografar em logs públicos):

```bash
export AWS_REGION=<REGION>
aws ssm get-parameters-by-path \
  --path /<PROJECT>/production --recursive \
  --query 'Parameters[].{Name:Name,Type:Type}' --output table
```

**Me responda com:** tabela Nome/Tipo (sem Values).

---

## Etapa 12 — Ligar deploy + primeiro rollout

**Objetivo:** publicar a app.

**Links:**
- Environment variables: `https://github.com/<OWNER/REPO>/settings/environments`
- Deploy workflow: `https://github.com/<OWNER/REPO>/actions/workflows/deploy.yml`

1. Altere `PRODUCTION_SSM_ENABLED` → `true`
2. Rode **Deploy to Production** (`workflow_dispatch` ou push em `<BRANCH>`)

O script remoto deve: `git pull` → `sync_config` → build → **`up -d --force-recreate --no-deps <app>`** → health.

**Me responda com:** link do run + últimas linhas do log (sem env/secrets).

---

## Etapa 13 — Health check

**Copiar/colar na EC2:**

```bash
curl -fsS http://127.0.0.1:<API_PORT><HEALTH_PATH>
docker compose --project-name <PROJECT> -f /opt/<PROJECT>-api/docker-compose.prod.yml ps
```

**Me responda com:** body/status do curl + `ps`.

---

## Etapa 14 — (Opcional) Cloudflare Pages + proxy

Só se houver SPA/cookies. Skill satélite: `.github/skills/cloudflare-pages-proxy/SKILL.md`.

**Links:**
- Cloudflare dashboard: https://dash.cloudflare.com/
- Workers & Pages: https://dash.cloudflare.com/?to=/:account/workers-and-pages
- Doc: `docs/cloudflare-pages.md`

**Checklist copy/paste:**
1. Criar projeto **Pages** (não só Worker Builds).
2. Copiar `templates/cloudflare/functions/` para o frontend.
3. Build com API URL vazia (same-origin).
4. Runtime var no **Pages**:

```text
BACKEND_API_URL=http://<PUBLIC_DNS>:<API_PORT>
```

5. **Redeploy** após salvar a var.
6. No SSM, `CORS_ORIGIN` inclui `https://<pages-project>.pages.dev` → novo `apply` se mudar.
7. Teste login + refresh + logout no browser.

**Me responda com:** URL `*.pages.dev` + “proxy ok” ou erro (Network tab).

---

## Etapa 15 — Sucesso

Marque completo só se:
- [ ] Health local 200
- [ ] Deploy via Actions com fingerprint
- [ ] Código novo entra no ar após recreate (sem 404 fantasma)
- [ ] (Se Pages) cookie/refresh funciona same-origin
- [ ] Nenhum secret commitado

Parabéns — Lean MVP no ar. Operação: budgets + Session Manager + `plan`/`apply` para config.

---

## Skills satélites

| Etapa / problema | Skill |
| --- | --- |
| 2 custo | `.github/skills/aws-cost-analysis` / `mcp-setup` |
| 3–4 máquina | `.github/skills/aws-ec2-bootstrap` |
| 5 / 10 OIDC | `.github/skills/github-actions-oidc` |
| 12–13 deploy | `.github/skills/production-deploy` |
| 14 Pages | `.github/skills/cloudflare-pages-proxy` |
| Falhas | `.github/skills/troubleshooting` |
