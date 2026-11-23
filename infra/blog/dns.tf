# 旧 infra/dns で管理していた Lightsail 向けの A レコードを取り込む
import {
  to = aws_route53_record.blog_a
  id = "${data.aws_route53_zone.main.zone_id}_${var.domain_name}_A"
}

resource "aws_route53_record" "blog_a" {
  provider = aws.dns
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = var.domain_name
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "blog_aaaa" {
  provider = aws.dns
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = var.domain_name
  type     = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
