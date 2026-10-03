
# 実際の値は terraform.tfvars に書く（コミットしない）
variable "bucket_name" {
  description = "サイトの S3 バケット名"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "サイトの CloudFront ディストリビューション ID"
  type        = string
}

variable "github_repository" {
  description = "サイトのコードを管理するリポジトリ（オーナー/リポジトリ名）"
  type        = string
}
