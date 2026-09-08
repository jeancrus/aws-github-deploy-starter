# Terraform de parâmetros SSM (esqueleto)

Copie este diretório para `infra/production-config/` no repositório do backend e complete os `aws_ssm_parameter` conforme `scripts/production/defaults.json` + secrets.

Não versionar valores reais. O workflow `templates/github-actions/production-config.yml` passa:

- `TF_VAR_configuration` ← `vars.PRODUCTION_CONFIG_JSON`
- `TF_VAR_secrets` ← `secrets.PRODUCTION_SECRETS_JSON`

```hcl
terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    key    = "production-config/terraform.tfstate"
    # bucket + region via -backend-config no workflow
  }
}

variable "aws_region" { type = string }
variable "configuration" { type = map(string) }
variable "secrets" { type = map(string) }

provider "aws" {
  region = var.aws_region
}

# Exemplo — adapte nomes e SecureString:
# resource "aws_ssm_parameter" "cors_origin" {
#   name  = "/<PROJECT>/production/CORS_ORIGIN"
#   type  = "String"
#   value = var.configuration["CORS_ORIGIN"]
# }
#
# resource "aws_ssm_parameter" "postgres_password" {
#   name  = "/<PROJECT>/production/POSTGRES_PASSWORD"
#   type  = "SecureString"
#   value = var.secrets["POSTGRES_PASSWORD"]
# }
```

Bootstrap IAM/state: `templates/cloudformation/bootstrap.yml`.
