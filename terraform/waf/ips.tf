resource "aws_wafv2_ip_set" "whitelist" {
  name               = "${replace(title(var.name), " ", "")}-Whitelist-IP-Set"
  description        = "Allow specific IP addresses for ${var.name}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = flatten([for ip_list in values(var.allowed_ip_cidr_blocks) : ip_list])
}

resource "aws_wafv2_ip_set" "blacklist" {
  name               = "${replace(title(var.name), " ", "")}-Blacklist-IP-Set"
  description        = "Disallow specific IP addresses for ${var.name}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist
}
