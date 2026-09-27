# admon-networks.com の TXT レコード
# - TXT の値を増やすときは、新しい resource を作らず、下の records に1行追加する
# - Route 53 では「同じ名前の TXT レコード」を2つ作れないため
resource "aws_route53_record" "txt_root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "TXT"
  ttl     = 300 # 移行中は変更をすぐ反映させるため短め。落ち着いたら 3600 にする

  records = [
    "google-site-verification=KAHuHMvtSHs03F2_xIgCWCEq4yor_gsILF-FatSfTJw", # Google Workspace の所有権確認  
  ]
}
