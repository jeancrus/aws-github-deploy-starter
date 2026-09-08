# AWS + GitHub Actions Deploy Starter

Steering canônico: leia antes de orientar mudanças. Skill Cursor: `.cursor/skills/lean-mvp-aws-deploy/`.

## Objetivo

Ajudar uma pessoa a criar uma implantação **Lean MVP** econômica e segura na AWS: EC2 + Docker Compose + SSM Parameter Store + GitHub Actions com OIDC, sem credenciais permanentes — e Cloudflare Pages opcional para SPA.

## Regras obrigatórias

- Nunca pedir, registrar ou commitar access keys, secret keys, senhas, tokens, conteúdo de `.pem` ou valores de produção.
- Nunca executar `terraform apply`, criar stack CloudFormation, abrir firewall amplo ou deploy real sem confirmação explícita.
- Sempre estimar custo e registrar premissas antes de recomendar arquitetura.
- Preferir Session Manager para administração e OIDC para GitHub Actions.
- Tratar a menor fatura como diferente do melhor custo-benefício.
- Usar placeholders até o usuário confirmar região, conta, aplicação e orçamento.
- Verificar arch (`aarch64`/`x86_64`) antes de sugerir CLI/imagens.
- Em deploy Compose com bind-mount + processo long-lived, exigir `--force-recreate` do serviço app.
- Em Pages: hostname (nunca IP), porta na `BACKEND_API_URL`, var no projeto Pages, redeploy após mudar var.

## Fluxo padrão (Lean MVP)

1. Descobrir objetivo, repos, região, orçamento, health e porta.
2. Verificar identidade AWS e pré-requisitos.
3. Consultar pricing/custos; preferir Graviton micro se couber.
4. Apresentar alternativas e pedir confirmação.
5. Preparar EC2, Docker, swap, Session Manager.
6. CloudFormation bootstrap (OIDC + state + EC2 profile) → anexar role.
7. Environment GitHub `production` (vars/secrets) + teste de identidade.
8. `plan` → confirmação → `apply` de parâmetros SSM; só então ligar `PRODUCTION_SSM_ENABLED`.
9. Deploy controlado (`deploy.sh`) + health; opcional Pages proxy.
10. Operar com budgets; diagnosticar sem logar SecureString.

## Referências

- [Guia completo](docs/getting-started.md)
- [Arquitetura](docs/architecture.md)
- [Cloudflare Pages](docs/cloudflare-pages.md)
- [Análise de custo](docs/cost-analysis.md)
- [Segurança](docs/security.md)
- [Compatibilidade com IAs e IDEs](docs/ai-ide-compatibility.md)
- [Troubleshooting](docs/troubleshooting.md)
- Templates em `templates/`
- Skills em `.github/skills/` e `.cursor/skills/`

## Pull Requests

Toda PR deve seguir `.github/pull_request_template.md` e conter objetivo, alteração, motivo, validação real e ações pós-merge. Sem secrets na descrição.
