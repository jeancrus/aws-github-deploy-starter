# MCP setup

Use esta skill quando o usuário pedir instalação ou configuração dos MCPs AWS Pricing e Billing/Cost Management.

## Procedimento

1. Explique que os MCPs rodam localmente no cliente de IA, não no GitHub Actions nem na EC2.
2. Verifique `uvx` e confirme o AWS profile e a região sem pedir access keys em texto.
3. Execute `bash scripts/install-mcps.sh` ou gere a configuração equivalente para o cliente escolhido.
4. Valide a identidade com `aws sts get-caller-identity` antes de consultar custos.
5. Não cole a configuração gerada em issues, commits ou logs se ela contiver contexto interno.
6. Se o cliente não suporta `wsl.exe`, adapte somente o launcher; mantenha os pacotes `awslabs.billing-cost-management-mcp-server` e `awslabs.aws-pricing-mcp-server`.
7. Teste a consulta de pricing/custos sem criar recursos e informe limitações dos dados retornados.

## Não fazer

- Não instalar os MCPs na EC2 por padrão.
- Não executar `terraform apply` como consequência da instalação.
- Não armazenar credenciais AWS no arquivo gerado.
- Não afirmar que a estimativa é uma cotação final sem verificar região, data e componentes.

