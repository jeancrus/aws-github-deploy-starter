# Troubleshooting

## OIDC não autorizado

Confira conta, região, role ARN, provider, audiência, repositório, branch e environment no `sub` do token. A policy precisa corresponder exatamente ao contexto do workflow.

## Fingerprint SSH incompatível

Não desative a verificação. Confirme o host, leia os fingerprints diretamente na instância e atualize o secret somente após validar rotação legítima.

## Session Manager não lista a instância

Verifique agente SSM, instance profile com `AmazonSSMManagedInstanceCore`, conectividade de saída e arquitetura/distribuição da AMI. Aguarde após anexar a role.

## GetParametersByPath negado

Confira região, caminho, `SecureString`, KMS key policy e permissões da role no ARN correto.

## Readiness falha

Veja `docker compose ps`, logs, variáveis, migrations, banco, Redis e health endpoint. Não faça rollback automático de banco sem procedimento testado.

