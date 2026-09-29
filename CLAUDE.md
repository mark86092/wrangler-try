# wrangler-try

Cloudflare Worker，只回傳 `{"status":"ok"}`，透過 Terraform 部署，網址為 https://warngler-try.markchen.cc。

## 工具安裝

使用 [mise](https://mise.jdx.dev) 管理工具版本（見 `mise.toml`：terraform、wrangler）：

```
mise install
```

## 環境設定

在專案根目錄建立 `mise.local.toml`（已被 `.gitignore` 排除，不可 commit）：

```toml
[env]
CLOUDFLARE_API_TOKEN = "<token>"
TF_VAR_account_id = "<Cloudflare account ID>"
```

- `CLOUDFLARE_API_TOKEN`：需要 Workers Scripts: Edit、Zone: Read，以及 Workers Routes / DNS 的編輯權限，另需 Access: Apps and Policies Edit（Zero Trust）。wrangler 與 Terraform provider 都會讀取。
- `TF_VAR_account_id`：Terraform 的 `account_id` variable。

## 指令

- 本機測試：`mise exec -- wrangler dev`，然後 `curl localhost:8787`
- 部署：`cd terraform && mise exec -- terraform init && mise exec -- terraform apply`

## 結構

- `src/index.js`：Worker 程式碼
- `wrangler.toml`：本機開發用的 wrangler 設定
- `terraform/main.tf`：部署設定（Worker script 與 `markchen.cc` 上的 Custom Domain）。網域 zone 必須已在同一個 Cloudflare account 內。另含 Zero Trust Access application 與 policy，只允許 `access_allowed_emails`（預設 `mark86092@gmail.com`）透過 One-time PIN 登入。

## 注意

- 部署一律用 Terraform，不要用 `wrangler deploy`，以免與 Terraform state 不一致。
- `workers.dev` subdomain 已關閉，只能透過 Custom Domain 存取。
