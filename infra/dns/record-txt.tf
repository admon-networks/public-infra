locals {
  # Google Workspace の DKIM 公開鍵
  # 管理コンソール（アプリ → Gmail → メールの認証）で生成した値をそのまま貼る
  dkim_google_value = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv1FO8wCe5RLs4yeIwqpJWtzJ59ofxYcXFrGc6el278pP8gZkcAJgBZdAMu1mRsk4aEt2WJCwaY0+HYH+pfnCvzAfVtDm4wp7rNO0IAywBVBZqvItXW5IG7Edcmylo4usKGXDsXIOidxcY8ZGLWOYOtMfN54QxtDS7SBte9gGbFX5r/DdsCleOxXVWBYYPTdn+PO16msZruHh7sVddM7jVSlVYuAoBXZmFhCY90oE4d+6scOPLMm2cANyuJ4j37D5EuKLC2VWO1piW0I4wKiZXMKlh+Daug19iG1sWNd1GOUheSmdpadviTFVVyiu2ciquAGU2UXhaBaDT32wSBwguQIDAQAB"

  # TXT レコードの文字列は1つ255文字までのため、255文字ごとに区切った値を作る
  # - regexall(".{1,255}", 値)：値を255文字ずつのかたまりに切り分けてリストにする
  # - join("\"\"", リスト)    ：かたまりを "" でつなぐ（Route 53 は "" を文字列の区切りとして扱う）
  dkim_google_record = join("\"\"", regexall(".{1,255}", local.dkim_google_value))
}

# admon-networks.com（ルートドメイン）
# - TXT の値を増やすときは、新しい resource を作らず、下の records に1行追加する
# - Route 53 では「同じ名前の TXT レコード」を2つ作れないため
# - SPF（v=spf1 で始まる値）は1つまで。送信元を増やすときは、この1行の中に追記する
resource "aws_route53_record" "txt_root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "TXT"
  ttl     = 300 # 移行中は変更をすぐ反映させるため短め。落ち着いたら 3600 にする

  records = [
    "google-site-verification=KAHuHMvtSHs03F2_xIgCWCEq4yor_gsILF-FatSfTJw", # Google Workspace の所有権確認
    "v=spf1 include:_spf.google.com ~all",                                  # SPF：Google Workspace からの送信を許可
  ]
}

# google._domainkey.admon-networks.com（DKIM）
# - Google Workspace から送るメールの電子署名を、受け取る側が確かめるための公開鍵
resource "aws_route53_record" "txt_dkim_google" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "google._domainkey.${local.domain_name}"
  type    = "TXT"
  ttl     = 300

  records = [local.dkim_google_record]
}

# _dmarc.admon-networks.com（DMARC）
# - SPF・DKIM の確認に失敗したメールの扱いを、受け取る側に伝える
# - 最初は p=none（何もしないで、結果のレポートだけ送ってもらう）で様子を見る
# - レポートで問題がないことを確認できたら、p=quarantine（迷惑メール扱い）に上げる
resource "aws_route53_record" "txt_dmarc" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_dmarc.${local.domain_name}"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=none; rua=mailto:dmarc@${local.domain_name}",
  ]
}
