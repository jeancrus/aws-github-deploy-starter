# GitHub Actions OIDC

Use OIDC com trust policy restrita. Verifique provider, audiência, subject, role ARN, environment e permissions. Não use access keys permanentes.

## Quando usar

Bootstrap de IAM para Actions escrever SSM / state, ou diagnóstico de `Not authorized to perform sts:AssumeRoleWithWebIdentity`.

## Padrão Lean MVP

1. **Uma vez:** CloudFormation `templates/cloudformation/bootstrap.yml`
   - S3 state versionado + encrypt
   - OIDC provider `token.actions.githubusercontent.com` **ou** `ExistingOidcProviderArn`
   - Role `ConfigRunnerRole` assumível só com:
     - `aud = sts.amazonaws.com`
     - `sub` ∈ `repo:<OWNER/REPO>:environment:production` **e** subject imutável equivalente
   - Instance profile EC2 com `GetParametersByPath` no prefixo SSM + `AmazonSSMManagedInstanceCore`
2. Copiar Outputs → variables do GitHub Environment `production`
3. Workflow de identidade: `templates/github-actions/identity.yml`
4. Workflow de parâmetros: `templates/github-actions/production-config.yml` (`id-token: write`)

## Checklist de trust

- [ ] Conta e região corretas
- [ ] Environment GitHub chama-se exatamente `production` (ou o nome no `sub`)
- [ ] Repositório no `sub` é o do **backend/config**, não o frontend
- [ ] Workflow tem `permissions: id-token: write`
- [ ] Job usa `environment: production`
- [ ] Role ARN em `vars.AWS_CONFIG_ROLE_ARN` é o Output do bootstrap
- [ ] Conta já tinha OIDC? → não criar segundo provider; passe ARN existente

## Subject imutável

GitHub emite claims estáveis `owner@id/repo@id`. Inclua **os dois** subjects (legado `owner/name` e imutável) na trust policy, como no template de bootstrap.

## Não fazer

- Access keys de longa duração no GitHub
- `sub` com `*` amplo (`repo:ORG/*`)
- Trust em `ref:refs/heads/main` se a intenção é só environment protegido (prefira `environment:production` + reviewers)
- Colar o conteúdo do `.pem` ou de `PRODUCTION_SECRETS_JSON` em issues/PRs
