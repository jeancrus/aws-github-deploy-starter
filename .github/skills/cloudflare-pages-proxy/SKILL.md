# Cloudflare Pages proxy

Configura SPA no Cloudflare Pages com Functions que fazem proxy same-origin para a API na EC2. Use quando houver frontend separado, cookies `SameSite`, ou erro `BACKEND_API_URL is not configured`.

## Por que proxy

Sem same-origin, cookies de refresh entre `*.pages.dev` e o host EC2 quebram (`SameSite=Lax`). O padrão: browser → Pages → Function → `BACKEND_API_URL`.

## Checklist

- [ ] Criar projeto **Pages** (não confundir com Worker Builds / Git Workers)
- [ ] Copiar `templates/cloudflare/functions/`
- [ ] Build com URL de API vazia (same-origin): ex. `VITE_API_URL=""`
- [ ] Runtime var no projeto Pages: `BACKEND_API_URL=http://ec2-….compute.amazonaws.com:<PORT>`
- [ ] Hostname DNS — **nunca IP literal**
- [ ] Incluir a **porta** da API
- [ ] Redeploy após criar/alterar a var
- [ ] `CORS_ORIGIN` no SSM inclui `https://<project>.pages.dev`
- [ ] Proxy remove header `host` (`headers.delete("host")`)

## Sintomas → causa

| Sintoma | Causa provável |
| --- | --- |
| `BACKEND_API_URL is not configured` | Var no projeto errado (Worker vs Pages) ou sem redeploy |
| Fetch falha / network error | IP cru em vez de hostname |
| API 404 / connection refused | Faltou `:<PORT>` na origin |
| Login ok, refresh/logout falha | Sem proxy / cookie cross-site |
| CORS error | `CORS_ORIGIN` sem a URL HTTPS do Pages |

## Deploy CI (opcional)

Template `templates/cloudflare/deploy-pages.yml`: secrets `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`; variable de gate `CLOUDFLARE_PAGES_DEPLOY_ENABLED`.

## Não fazer

- Colocar secrets da API no frontend
- Apontar Pages para IP
- Assumir que variável do dashboard “Workers” vale para Pages Functions
