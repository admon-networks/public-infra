# 旧ドメイン（tech-lablog.com）から blog.admon-networks.com への 301 転送
# ブログ本体とは別のディストリビューションにして、本番の証明書や設定に触れずに済むようにする。
# 旧ドメインをやめるときは、このファイルを消して apply すればよい

locals {
  legacy_domain = "tech-lablog.com"
}

# 旧ドメインのホストゾーン（管理アカウント）
data "aws_route53_zone" "legacy" {
  provider = aws.dns
  name     = local.legacy_domain
}

# 旧ドメイン用の証明書（CloudFront に付けるので us-east-1）
resource "aws_acm_certificate" "legacy" {
  provider                  = aws.us_east_1
  domain_name               = local.legacy_domain
  subject_alternative_names = ["www.${local.legacy_domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# DNS 検証用のレコード（証明書の自動更新にも使うので、消さないこと）
resource "aws_route53_record" "legacy_cert_validation" {
  provider = aws.dns

  for_each = {
    for dvo in aws_acm_certificate.legacy.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.legacy.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "legacy" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.legacy.arn
  validation_record_fqdns = [for r in aws_route53_record.legacy_cert_validation : r.fqdn]
}

# どのパスに来ても、blog.admon-networks.com の同じパスへ 301 で転送する
resource "aws_cloudfront_function" "legacy_redirect" {
  name    = "blog-prod-cff-legacy-redirect"
  runtime = "cloudfront-js-2.0"
  comment = "tech-lablog.com から blog.admon-networks.com への 301 転送"
  publish = true
  code    = file("${path.module}/functions/legacy-redirect.js")
}

resource "aws_cloudfront_distribution" "legacy" {
  enabled         = true
  comment         = "tech-lablog.com -> blog.admon-networks.com (301)"
  aliases         = [local.legacy_domain, "www.${local.legacy_domain}"]
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = "PriceClass_200"

  # 関数がすべてのリクエストに転送を返すので、オリジンには実際には届かない。
  # ただし CloudFront ではオリジンの指定が必須なので、ブログのバケットを指定しておく
  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id = local.s3_origin_id
    # http で来ても、いったん https に転送せず、新ドメインの https へ1回で転送する
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.legacy_redirect.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.legacy.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# Lightsail を向いている既存の A レコードを取り込んで、転送用の CloudFront に向け直す
import {
  to = aws_route53_record.legacy_apex_a
  id = "${data.aws_route53_zone.legacy.zone_id}_${local.legacy_domain}_A"
}

resource "aws_route53_record" "legacy_apex_a" {
  provider = aws.dns
  zone_id  = data.aws_route53_zone.legacy.zone_id
  name     = local.legacy_domain
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.legacy.domain_name
    zone_id                = aws_cloudfront_distribution.legacy.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "legacy_apex_aaaa" {
  provider = aws.dns
  zone_id  = data.aws_route53_zone.legacy.zone_id
  name     = local.legacy_domain
  type     = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.legacy.domain_name
    zone_id                = aws_cloudfront_distribution.legacy.hosted_zone_id
    evaluate_target_health = false
  }
}
