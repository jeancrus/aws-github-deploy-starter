# Terraform boundary (VM lean)

Este diretório é o lugar para o Terraform **da máquina** (VPC, SG, EC2, EIP) do projeto consumidor.

O starter **não** aplica nada automaticamente. Depois de custo e confirmação humana:

1. Copie ou gere módulos lean (preferência: `t4g.micro` + Ubuntu arm64 + EBS pequeno).
2. Security Group mínimo (ver skill `aws-ec2-bootstrap`).
3. `user_data` pode espelhar `templates/scripts/bootstrap-ec2.sh` (swap + Docker).
4. Instance profile: anexe o Output `Ec2InstanceProfileName` do CloudFormation `templates/cloudformation/bootstrap.yml` (não invente access keys na VM).

A **configuração da aplicação** (SSM) fica em `infra/production-config/` no repo do backend — separada deste Terraform de VM. Ver `docs/architecture.md`.
