# admon-networks.com の MX レコード（メールの届け先）
# - Google Workspace（Gmail）で受信する
resource "aws_route53_record" "mx_root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "MX"
  ttl     = 300 # 移行中は短め。落ち着いたら 3600 にする

  records = [
    "1 smtp.google.com", # 優先度 1 / Google Workspace の受信サーバー
  ]
}
