# GitHub Actions が AWS に認証するための OIDC プロバイダー
# アカウントに1つだけ作り、各リポジトリのデプロイ用ロールから共通で参照する
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  # トークンの宛先（audience）。aws-actions/configure-aws-credentials が使う値
  client_id_list = ["sts.amazonaws.com"]

  # 消すと、これを使うすべてのリポジトリの Actions が AWS に認証できなくなる
  lifecycle {
    prevent_destroy = true
  }
}
