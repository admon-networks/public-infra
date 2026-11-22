output "bucket_name" {
  description = "デプロイ先の S3 バケット名"
  value       = aws_s3_bucket.site.bucket
}

output "distribution_id" {
  description = "キャッシュ削除に使う CloudFront ディストリビューション ID"
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_domain_name" {
  description = "切り替え前の動作確認に使う CloudFront のドメイン（xxxx.cloudfront.net）"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Route 53 のエイリアスレコードに使う CloudFront のホストゾーン ID"
  value       = aws_cloudfront_distribution.site.hosted_zone_id
}
