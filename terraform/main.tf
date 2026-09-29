terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# 從環境變數 CLOUDFLARE_API_TOKEN 讀取 token
provider "cloudflare" {}

variable "account_id" {
  type        = string
  description = "Cloudflare account ID"
}

resource "cloudflare_workers_script" "api" {
  account_id         = var.account_id
  script_name        = "wrangler-try"
  content            = file("${path.module}/../src/index.js")
  main_module        = "index.js"
  compatibility_date = "2026-09-29"
}


data "cloudflare_zones" "markchen" {
  name = "markchen.cc"
}

resource "cloudflare_workers_custom_domain" "api" {
  account_id = var.account_id
  zone_id    = data.cloudflare_zones.markchen.result[0].id
  hostname   = "warngler-try.markchen.cc"
  service    = cloudflare_workers_script.api.script_name
}

variable "access_allowed_emails" {
  type        = list(string)
  description = "允許通過 Cloudflare Access 的 email 清單"
  default     = ["mark86092@gmail.com"]
}

# Zero Trust Access：只有名單內的 email 可透過 One-time PIN 登入
resource "cloudflare_zero_trust_access_policy" "allow_emails" {
  account_id = var.account_id
  name       = "wrangler-try allow emails"
  decision   = "allow"
  include = [for email in var.access_allowed_emails : {
    email = { email = email }
  }]
}

resource "cloudflare_zero_trust_access_application" "api" {
  account_id       = var.account_id
  name             = "wrangler-try"
  domain           = cloudflare_workers_custom_domain.api.hostname
  type             = "self_hosted"
  session_duration = "24h"
  policies = [{
    id         = cloudflare_zero_trust_access_policy.allow_emails.id
    precedence = 1
  }]
}
