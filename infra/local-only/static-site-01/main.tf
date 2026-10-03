
locals {
  name = "static-site-01"
}

# OIDC プロバイダーは infra/github-oidc で作成済みのものを参照する
data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

# ID から ARN を引く（存在しない ID なら plan の時点でエラーになる）
data "aws_cloudfront_distribution" "site" {
  id = var.cloudfront_distribution_id
}

module "deploy_role" {
  source = "../../modules/github-deploy-role"

  role_name         = "${local.name}-prod-role-deploy"
  oidc_provider_arn = data.aws_iam_openid_connect_provider.github_actions.arn
  github_repository = var.github_repository
  bucket_arn        = "arn:aws:s3:::${var.bucket_name}"
  distribution_arn  = data.aws_cloudfront_distribution.site.arn
}
