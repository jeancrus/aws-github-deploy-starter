# Configurar OIDC

Siga `.github/skills/github-actions-oidc/SKILL.md` e o template `templates/cloudformation/bootstrap.yml`.

Passos: stack CloudFormation → Outputs → vars do Environment `production` → workflow `identity.yml` → só então `production-config` plan/apply.

Confirme se a conta já tem `token.actions.githubusercontent.com` (use `ExistingOidcProviderArn`). Não crie access keys.
