# GitHub Actions から本番アカウントにデプロイするための設定

# GitHub Actions 用の OIDC プロバイダー（AWS アカウントに1つだけ作るもの）
# 本番アカウントで使うのは今のところブログだけなので、このスタックで管理する
resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # 消すと、これを使うすべてのリポジトリの Actions が AWS に認証できなくなる
  lifecycle {
    prevent_destroy = true
  }
}

# ブログのリポジトリの main ブランチからだけ引き受けられるデプロイ用ロール
module "deploy_role" {
  source = "../modules/github-deploy-role"

  role_name         = "blog-prod-role-github-deploy"
  oidc_provider_arn = aws_iam_openid_connect_provider.github_actions.arn
  # 2026年7月以降に作ったリポジトリは、OIDC トークンの sub にオーナーとリポジトリの数値 ID が入る
  github_repository = "admon-networks@255683541/blog.admon-networks.com@1467266978"
  bucket_arn        = aws_s3_bucket.site.arn
  distribution_arn  = aws_cloudfront_distribution.site.arn
}
