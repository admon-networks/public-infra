# domain-registration（ローカル実行専用）

admon-networks.com のドメイン登録の設定（自動更新・移管ロック・WHOIS 非公開）を管理する。

## ローカル実行専用にしている理由

ドメイン登録のリソースは、登録者の連絡先（氏名・住所・電話番号）を state に持つ。
import や `terraform state show` を実行すると、それが画面に表示される。

## 運用ルール

- CI/CD（GitHub Actions など）では実行しない
- plan / apply は手元の端末でのみ実行する
- plan や state の出力を記事や SNS に貼るときは、連絡先のブロックを必ず削除する
