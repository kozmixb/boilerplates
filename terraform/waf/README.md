
```tf
module "default_waf" {
  count = var.enable_default_waf ? 1 : 0

  source                = "./modules/waf"
  allowed_country_codes = ["GB", "US"]
  allowed_ip_cidr_blocks = {
    example = [
      "192.168.1.2/32",
    ]
  }
  blacklist = [
    "192.168.1.1/32"
  ]
}
```
