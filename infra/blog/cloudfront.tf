# S3 へ署名付きでアクセスするための設定（OAC）
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "blog-prod-oac-site"
  description                       = "blog.admon-networks.com の S3 オリジン用"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# /slug/ → /slug/index.html の書き換えと、旧ドメインからの 301 転送
resource "aws_cloudfront_function" "viewer_request" {
  name    = "blog-prod-cff-viewer-request"
  runtime = "cloudfront-js-2.0"
  comment = "index.html の補完と旧ドメインからの転送"
  publish = true
  code    = file("${path.module}/functions/viewer-request.js")
}

# AWS が用意しているキャッシュポリシー（オリジンの Cache-Control に従う）
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# AWS が用意しているセキュリティヘッダー（HSTS など）。CSP は第2段階で独自のポリシーに置き換える
data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

locals {
  s3_origin_id = "s3-site"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  comment             = "blog.admon-networks.com"
  aliases             = [var.domain_name]
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  # 日本を含む主要な地域だけで配信して、料金を抑える
  price_class = "PriceClass_200"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer_request.arn
    }
  }

  # OAC の構成では、存在しないファイルに S3 は 403 を返すので、403 も 404 ページにする
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
