# blog は infra/blog スタックへ移管（レコード自体は削除しない）
removed {
  from = aws_route53_record.a_blog

  lifecycle {
    destroy = false
  }
}

# admon-networks.com と www は、停止中の Lightsail を向いていたため削除した。
# トップページ（ポートフォリオ）を作るときに、CloudFront 向けのエイリアスとして作り直す。
