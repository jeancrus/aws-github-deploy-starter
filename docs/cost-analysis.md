# Análise de custo-benefício

Os MCPs abaixo são ferramentas locais do cliente de IA. Não são executados pelo GitHub Actions e não devem ser instalados na EC2 sem decisão específica.

```json
{
  "aws-cost-management": {
    "type": "stdio",
    "command": "wsl.exe",
    "args": ["bash", "-lc", "uvx awslabs.billing-cost-management-mcp-server@latest"],
    "env": {"AWS_PROFILE": "default", "AWS_REGION": "<AWS_REGION>"}
  },
  "aws-pricing": {
    "type": "stdio",
    "command": "wsl.exe",
    "args": ["bash", "-lc", "uvx awslabs.aws-pricing-mcp-server@latest"],
    "env": {"AWS_PROFILE": "default", "AWS_REGION": "<AWS_REGION>"}
  }
}
```

O `aws-pricing` compara famílias, arquitetura, região, EBS, IP e transferência. O `aws-cost-management` verifica gasto atual, recursos ociosos, budgets e desvios. Nenhum resultado substitui a revisão da conta e do pricing vigente.

## Método

1. Defina região, orçamento, carga e janela de disponibilidade.
2. Compare ao menos uma instância ARM64 e uma x86 compatível.
3. Inclua armazenamento, snapshots, IPv4, tráfego, CloudWatch e dependências.
4. Avalie on-demand, savings plans e spot separadamente.
5. Não use Spot para produção persistente sem recuperação testada.
6. Registre data, premissas, tipo escolhido e alternativas rejeitadas.

## Registro mínimo

```text
Data:
Conta/região:
Orçamento mensal:
Carga esperada:
Opção escolhida:
Estimativa mensal:
Alternativas consideradas:
Custos não incluídos:
Riscos e gatilho de revisão:
Responsável pela aprovação:
```

