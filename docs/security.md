# Segurança e guardrails

- Use MFA, CloudTrail, budgets e alertas de billing.
- Use IAM roles e GitHub OIDC; não use access keys permanentes no workflow.
- Restrinja trust policy por repositório e environment.
- Separe permissões de plan e apply quando possível.
- Não exponha SSH sem necessidade; prefira Session Manager.
- Restrinja Security Groups por origem, porta e protocolo.
- Criptografe EBS, SSM SecureString e Secrets Manager.
- Redija logs e outputs para nunca exibirem secrets.
- Faça rotação de deploy keys, fingerprints e secrets.
- `apply`, firewall e recursos pagos exigem confirmação humana.

