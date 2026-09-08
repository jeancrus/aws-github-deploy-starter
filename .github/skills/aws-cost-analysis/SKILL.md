# AWS cost analysis

Use antes de escolher EC2. Leia `AGENTS.md` e `docs/cost-analysis.md`, confirme região e orçamento, consulte Pricing/Cost Management quando disponíveis e produza comparação com premissas.

## Procedimento

1. Confirmar região, orçamento, carga e janela de disponibilidade.
2. Comparar ao menos uma opção **ARM64 (t4g.\*)** e uma **x86** compatível.
3. Incluir EBS, IPv4/EIP, transferência, snapshots e logs.
4. Para Lean MVP: destacar que ALB/RDS/NAT costuram a fatura — default é Compose na mesma EC2.
5. Registrar escolha em `generated/decision-record.md`.
6. Pedir aprovação humana antes de provisionar.

Não criar recursos. Não tratar o preço mínimo como decisão automática.
