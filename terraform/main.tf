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
