# Lean MVP — referência (links, pitfalls, árvore)

Complemento da skill. O agente deve preferir o passo a passo em `SKILL.md`; use isto para URLs extras e diagnóstico.

## Painéis AWS (substitua `<REGION>`)

| Recurso | URL |
| --- | --- |
| EC2 Home | `https://console.aws.amazon.com/ec2/home?region=<REGION>` |
| Instances | `https://console.aws.amazon.com/ec2/home?region=<REGION>#Instances:` |
| Key pairs | `https://console.aws.amazon.com/ec2/home?region=<REGION>#KeyPairs:` |
| Security Groups | `https://console.aws.amazon.com/ec2/home?region=<REGION>#SecurityGroups:` |
| Elastic IPs | `https://console.aws.amazon.com/ec2/home?region=<REGION>#Addresses:` |
| CloudFormation | `https://console.aws.amazon.com/cloudformation/home?region=<REGION>` |
| Create stack | `https://console.aws.amazon.com/cloudformation/home?region=<REGION>#/stacks/create/template` |
| IAM OIDC providers | `https://console.aws.amazon.com/iam/home#/identity_providers` |
| IAM Roles | `https://console.aws.amazon.com/iam/home#/roles` |
| SSM Parameters | `https://console.aws.amazon.com/systems-manager/parameters/?region=<REGION>&tab=Table` |
| Session Manager | `https://<REGION>.console.aws.amazon.com/systems-manager/session-manager?region=<REGION>` |
| Billing / Budgets | `https://console.aws.amazon.com/billing/home#/budgets` |

## Painéis GitHub (substitua `<OWNER/REPO>`)

| Recurso | URL |
| --- | --- |
| Environments | `https://github.com/<OWNER/REPO>/settings/environments` |
| Deploy keys | `https://github.com/<OWNER/REPO>/settings/keys` |
| Actions | `https://github.com/<OWNER/REPO>/actions` |
| Secrets tip | nunca cole `EC2_SSH_KEY` / JSON de secrets no chat |

## Cloudflare

| Recurso | URL |
| --- | --- |
| Dashboard | https://dash.cloudflare.com/ |
| Workers & Pages | https://dash.cloudflare.com/?to=/:account/workers-and-pages |

## Árvore mínima no backend

```text
<app>-api/
├── docker-compose.prod.yml
├── infra/
│   ├── terraform/                 # VM lean (opcional)
│   └── production-config/
│       ├── bootstrap.yml
│       └── main.tf                # SSM
├── scripts/
│   ├── bootstrap-ec2.sh
│   └── production/
│       ├── defaults.json
│       ├── sync_config.py
│       ├── check_inputs.py
│       └── deploy.sh
└── .github/workflows/
    ├── deploy.yml
    ├── production-config.yml
    └── identity.yml
```

Frontend SPA: `templates/cloudflare/`.

## Placeholders

`<PROJECT>`, `<OWNER/REPO>`, `<OIDC_IMMUTABLE_SUB>`, `<REGION>`, `<SSM_PREFIX>`, `<APP_DIR>`, `<RUNTIME_DIR>`, `<API_PORT>`, `<HEALTH_PATH>`, `<BRANCH>`.

## Pitfalls

1. Sem `--force-recreate` → rota nova 404 com código já no disco.
2. Pages ≠ Worker Builds para `BACKEND_API_URL`.
3. Hostname, nunca IP cru, no proxy.
4. `BACKEND_API_URL` com `:<PORT>`.
5. Mudou var Pages → redeploy.
6. Proxy: `headers.delete("host")`.
7. Cookie SameSite sem proxy same-origin quebra refresh.
8. `CORS_ORIGIN` HTTPS alinhado ao Pages.
9. Placeholders `SUBSTITUA_*` / secrets no git.
10. Senha Postgres no volume ≠ SSM → abortar.
11. Um OIDC provider por conta → `ExistingOidcProviderArn`.
12. Arch AMI = arch AWS CLI/imagens.
13. Swap em t4g.micro.
14. Não logar SecureString / `candidate.json`.
15. Deploy só na branch de produção + tree limpa.
16. 5432 nunca público.

## Diagnóstico sem secrets

```bash
aws sts get-caller-identity
aws ssm get-parameters-by-path --path /<PROJECT>/production --recursive \
  --query 'Parameters[].{Name:Name,Type:Type}' --output table
curl -fsS http://127.0.0.1:<API_PORT><HEALTH_PATH>
```
