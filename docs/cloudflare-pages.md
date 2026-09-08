# Cloudflare Pages + proxy para EC2

Use quando o frontend é SPA separado e a API está na EC2 (especialmente com cookies de sessão/refresh).

## Setup

1. Crie um projeto **Cloudflare Pages** (não use só Worker Builds ligados ao Git como substituto).
2. Copie `templates/cloudflare/functions/` para o repo do frontend.
3. Build com API URL vazia (same-origin), ex.: `VITE_API_URL=""`.
4. No dashboard do projeto Pages, variável de runtime:

   `BACKEND_API_URL=http://ec2-….compute.amazonaws.com:<PORT>`

5. Faça um **novo deploy** depois de criar/alterar a variável.
6. No SSM da API, `CORS_ORIGIN` deve incluir `https://<seu-projeto>.pages.dev`.

## Regras que quebram em silêncio

| Regra | Errado | Certo |
| --- | --- | --- |
| Host | IP `http://1.2.3.4:3000` | Hostname `http://ec2-….amazonaws.com:3000` |
| Porta | Sem porta | Com `:<PORT>` |
| Projeto | Var só no Worker Builds | Var no **Pages** |
| Proxy | Encaminha `Host` original | `headers.delete("host")` |
| Cookie | Front em Pages, API em outro site sem proxy | Same-origin via `/api` |

## CI opcional

`templates/cloudflare/deploy-pages.yml` — secrets `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`; vars `CLOUDFLARE_PAGES_DEPLOY_ENABLED`, `CLOUDFLARE_PAGES_PROJECT_NAME`.

Comando manual típico: `npx wrangler pages deploy dist --project-name=<nome>`.
