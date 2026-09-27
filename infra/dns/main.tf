locals {
  domain_name = "admon-networks.com"
}

# ホストゾーン
resource "aws_route53_zone" "main" {
  name    = local.domain_name
  comment = "HostedZone created by Route53 Registrar"

  lifecycle {
    prevent_destroy = true
  }
}
