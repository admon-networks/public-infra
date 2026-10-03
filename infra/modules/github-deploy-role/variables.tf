
variable "role_name" {
  description = "作成する IAM ロールの名前"
  type        = string
}

variable "oidc_provider_arn" {
  description = "GitHub Actions 用 OIDC プロバイダーの ARN"
  type        = string
}

variable "github_repository" {
  description = "ロールを引き受けられるリポジトリ（オーナー/リポジトリ名）"
  type        = string
}

variable "github_branch" {
  description = "ロールを引き受けられるブランチ"
  type        = string
  default     = "main"
}

variable "bucket_arn" {
  description = "反映先の S3 バケットの ARN"
  type        = string
}

variable "distribution_arn" {
  description = "キャッシュを削除する CloudFront ディストリビューションの ARN"
  type        = string
}
