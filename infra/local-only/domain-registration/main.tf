locals {
  domain_name = "admon-networks.com"
}

# ドメイン登録の設定
# - 連絡先を state に持つため、このスタックはローカル実行専用（README 参照）
# - destroy してもドメインは解約されず、Terraform の管理から外れるだけなので
#   prevent_destroy は付けていない
# - 連絡先（氏名・住所・電話番号）は、公開リポジトリのため書かない
#   （書かなければ Terraform はこの項目を管理しない）
# - ネームサーバーは、並び順の違いだけで差分が出続けることがあるため管理しない
resource "aws_route53domains_registered_domain" "main" {
  domain_name = local.domain_name

  auto_renew    = true # 更新忘れによる失効を防ぐ
  transfer_lock = true # 第三者による不正な移管を防ぐ

  # WHOIS に連絡先を表示しない
  admin_privacy      = true
  registrant_privacy = true
  tech_privacy       = true
  billing_privacy    = true
}
