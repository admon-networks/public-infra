data "aws_caller_identity" "current" {}

locals {
  # バケット名は世界で一意なので、命名規則の後ろにアカウント ID を付ける
  bucket_name = "blog-prod-s3-site-${data.aws_caller_identity.current.account_id}"
}

# サイトのファイル（Astro のビルド結果）を置くバケット
resource "aws_s3_bucket" "site" {
  bucket = local.bucket_name
}

# パブリックアクセスはすべて禁止（CloudFront の OAC 経由でだけ読ませる）
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ACL を使わず、バケットの持ち主がすべてのオブジェクトを所有する
resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# 誤って上書き・削除したときに戻せるよう、バージョニングを有効にする
resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 古いバージョンは 30 日で消す（デプロイのたびに増え続けるのを防ぐ）
resource "aws_s3_bucket_lifecycle_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  depends_on = [aws_s3_bucket_versioning.site]
}

# 保存時の暗号化（S3 管理キー）
resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# このディストリビューションからの読み取りだけを許可する
data "aws_iam_policy_document" "site" {
  statement {
    sid       = "AllowCloudFrontRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json

  depends_on = [aws_s3_bucket_public_access_block.site]
}
