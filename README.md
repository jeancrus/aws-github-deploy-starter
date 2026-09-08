# AWS + GitHub Actions Deploy Starter

[![Validate starter](https://github.com/jeancrus/aws-github-deploy-starter/actions/workflows/validate.yml/badge.svg)](https://github.com/jeancrus/aws-github-deploy-starter/actions/workflows/validate.yml)

Kit e skill para sair de zero até um **Lean MVP online na AWS**: EC2 barata (Graviton), Docker Compose, SSM Parameter Store, GitHub Actions com OIDC e (opcional) Cloudflare Pages com proxy same-origin.

Desenhado para pessoas e IAs/IDEs. Pergunta decisões, registra premissas e deixa create/apply/deploy cobrado sob confirmação humana.

## Comece aqui

```bash
git clone https://github.com/jeancrus/aws-github-deploy-starter.git
cd aws-github-deploy-starter
bash scripts/check-prerequisites.sh
bash scripts/decision-wizard.sh
```

Depois siga [docs/getting-started.md](docs/getting-started.md).

No Cursor, a skill principal é `.cursor/skills/lean-mvp-aws-deploy/` — ela conduz **uma etapa por vez** com links de console e comandos para copiar/colar. Peça “seguir o Lean MVP AWS deploy” ou abra a skill.

## Incluído

- Roteiro completo do padrão Arenex/SSM (máquina ≠ config ≠ deploy).
- Skills para EC2, OIDC, deploy com `--force-recreate`, Pages proxy, custo e troubleshooting.
- Templates prontos para copiar: CloudFormation bootstrap, `deploy.sh`, `sync_config.py`, workflows, Compose e Functions.
- Comparação de custo EC2/EBS/IP; setup dos MCPs de Pricing e Billing.
- Steerings para AGENTS.md, Claude, Copilot e Cursor.
- Guardrails contra secrets, apply acidental e recursos caros.

O starter orienta e gera artefatos; **não** provisiona AWS sozinho.

## Arquitetura em uma frase

GitHub OIDC escreve SSM → EC2 lê SSM e sobe Compose → Pages (opcional) faz proxy `/api` para o hostname:porta da EC2.

Detalhes: [docs/architecture.md](docs/architecture.md).

## Segurança

Nunca coloque `.pem`, access keys, senhas ou valores de produção neste repositório. Leia [docs/security.md](docs/security.md).
