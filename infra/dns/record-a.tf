locals {
  blog_server_ip = "35.76.223.118" # Lightsail（WordPress-1）の固定IP
}

# blog.admon-networks.com：ブログ本体
resource "aws_route53_record" "a_blog" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "blog.${local.domain_name}"
  type    = "A"
  ttl     = 300

  records = [local.blog_server_ip]
}

# admon-networks.com（ルートドメイン）
# - トップページ（S3 + CloudFront）ができるまでは、ブログのサーバーに向け、
#   サーバー側で blog.admon-networks.com へ転送する
resource "aws_route53_record" "a_root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "A"
  ttl     = 300

  records = [local.blog_server_ip]
}

# www.admon-networks.com
# - 今はブログのサーバーに向け、サーバー側で blog.admon-networks.com へ転送する
resource "aws_route53_record" "a_www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${local.domain_name}"
  type    = "A"
  ttl     = 300

  records = [local.blog_server_ip]
}
