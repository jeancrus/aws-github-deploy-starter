# Compatibilidade com IAs e IDEs

O contrato canônico está em `AGENTS.md`. Adaptadores leves apontam para o mesmo contrato:

- Claude: `CLAUDE.md`.
- GitHub Copilot: `.github/copilot-instructions.md`.
- Cursor: `.cursor/rules/aws-deploy.mdc`.
- OpenCode/Codex: leia `AGENTS.md` e use os prompts em `.github/prompts/`.

Ao portar para outra ferramenta, preserve regras de segurança, perguntas de descoberta e confirmação. Não duplique instruções divergentes.

