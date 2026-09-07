# AWS + GitHub Actions Deploy Starter

Este arquivo é o steering principal do projeto e deve ser lido por qualquer IA ou IDE antes de orientar mudanças.

## Objetivo

Ajudar uma pessoa a criar uma implantação de produção econômica e segura na AWS, usando EC2, Docker e GitHub Actions com OIDC, sem expor credenciais permanentes.

## Regras obrigatórias

- Nunca pedir, registrar ou commitar access keys, secret keys, senhas, tokens, conteúdo de `.pem` ou valores de produção.
- Nunca executar `terraform apply`, criar recursos pagos ou alterar firewall sem confirmação explícita.
- Sempre estimar custo e registrar premissas antes de recomendar uma arquitetura.
- Preferir Session Manager para administração e OIDC para GitHub Actions.
- Tratar a menor fatura como diferente do melhor custo-benefício.
- Usar placeholders até o usuário confirmar região, conta, aplicação e orçamento.
- Verificar arquitetura, distribuição e permissões antes de sugerir comandos.

## Fluxo padrão

1. Descobrir objetivo, aplicação, região, orçamento e disponibilidade.
2. Verificar identidade AWS e pré-requisitos localmente.
3. Consultar pricing e custos atuais antes de escolher a EC2.
4. Apresentar alternativas e pedir confirmação.
5. Preparar EC2, acesso administrativo e runtime.
6. Configurar IAM/OIDC, environment e secrets do GitHub.
7. Executar `plan`, revisar e pedir confirmação para `apply`.
8. Fazer deploy controlado e validar health check, logs e rollback.

## Referências

- [Guia completo](docs/getting-started.md)
- [Análise de custo](docs/cost-analysis.md)
- [Segurança](docs/security.md)
- [Compatibilidade com IAs e IDEs](docs/ai-ide-compatibility.md)
- [Troubleshooting](docs/troubleshooting.md)

