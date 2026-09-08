# EC2 bootstrap

Conduza rede, Security Group, EC2, EBS, instance profile, Docker e Session Manager em etapas. Mostre impacto e peça confirmação antes de operações cobradas ou destrutivas.

## Quando usar

Criar ou preparar a máquina Lean MVP (Graviton preferido) onde o Compose vai rodar.

## Decisões antes de criar

1. Região e orçamento já registrados em `generated/decision-record.md`
2. Arch: preferir **arm64 / t4g.*** se a stack for multi-arch
3. Disponibilidade: Lean = 1 AZ; HA fica para depois
4. Acesso admin: Session Manager preferido; SSH só de CIDR temporário `/32`

## Security Group mínimo

| Porta | Quem | Notas |
| --- | --- | --- |
| 22 | CIDR admin ou ausente | Remover quando SSM estiver ok |
| `<API_PORT>` | 0.0.0.0/0 só se o proxy/front precisar | Preferir hostname + Pages |
| 5432 / Redis | **nunca público** | Só rede Docker interna |

## Checklist da instância

- [ ] AMI Ubuntu (ou equivalente) na arch correta
- [ ] Volume EBS criptografado, tamanho mínimo viável
- [ ] Tags de dono/projeto
- [ ] EIP se precisar de DNS estável para Pages (`ec2-….amazonaws.com` ou DNS próprio)
- [ ] **Não** anexar role ainda se o CloudFormation bootstrap ainda não rodou — anexe o profile dos Outputs depois

## Runtime na primeira conexão

Script de referência: `templates/scripts/bootstrap-ec2.sh`.

1. Confirmar `uname -m`
2. Swap ~2G em `t4g.micro` / micros com build
3. Docker Engine + Compose plugin
4. SSM Agent (`snap` no Ubuntu) → `active`
5. AWS CLI na arch correta
6. Dirs: `/opt/<project>-api` (0755) e `/opt/<project>-runtime` (0700)
7. Deploy key RO → clone da branch de produção

Validar:

```bash
docker --version
docker compose version
aws sts get-caller-identity
```

## Não fazer

- Abrir 0.0.0.0/22
- Expor banco
- Instalar access keys na EC2 (use instance profile)
- Assumir que `apt install awscli` traz a arch certa no Graviton
