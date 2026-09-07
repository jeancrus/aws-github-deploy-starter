# AWS + GitHub Actions Deploy Starter

Um guia e kit interativo para sair de zero até um deploy de produção na AWS usando EC2, Docker e GitHub Actions.

O projeto foi desenhado para pessoas e diferentes IAs/IDEs. Ele pergunta decisões importantes, registra premissas e deixa a execução destrutiva sob confirmação humana.

## Comece aqui

```bash
git clone https://github.com/jeancrus/aws-github-deploy-starter.git
cd aws-github-deploy-starter
bash scripts/check-prerequisites.sh
bash scripts/decision-wizard.sh
```

Depois siga [docs/getting-started.md](docs/getting-started.md).

## Incluído

- Roteiro completo de AWS + GitHub Actions desde zero.
- Comparação de custo para EC2, EBS, IP e transferência.
- Configuração local dos MCPs AWS Pricing e Billing/Cost Management.
- Steerings portáveis para AGENTS.md, Claude, Copilot e Cursor.
- Prompts para descoberta, custo, EC2, OIDC, deploy e diagnóstico.
- Templates de workflows para `plan`, `apply` e deploy.
- Guardrails contra segredos, `apply` acidental e recursos caros.

O starter orienta e gera artefatos; ele não provisiona AWS automaticamente. A infraestrutura precisa ser revisada e aprovada pelo responsável da conta.

## Segurança

Nunca coloque `.pem`, access keys, senhas ou valores de produção neste repositório. Leia [docs/security.md](docs/security.md).

