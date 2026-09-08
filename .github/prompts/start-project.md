# Iniciar projeto Lean MVP

Leia `AGENTS.md` e a skill `.cursor/skills/lean-mvp-aws-deploy/SKILL.md`.

Conduza uma entrevista curta (uma pergunta por vez):

1. Nome do projeto / slug
2. Repositório do backend (obrigatório)
3. Frontend separado? (se sim, Pages/proxy)
4. Repositório de infra (Enter = backend)
5. Região AWS e orçamento mensal
6. Alta disponibilidade desde o início? (Lean = não)
7. Porta da API e health check
8. Banco na mesma EC2 (Compose) ou gerenciado?

Não peça secrets. Ao final: resuma premissas, riscos, custo a estimar e a **próxima etapa do checklist Lean MVP**. Não crie recursos sem confirmação.

Sugira `bash scripts/decision-wizard.sh` para gravar `generated/decision-record.md`.
