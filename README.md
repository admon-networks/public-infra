# public-infra

[Admon Networks](https://blog.admon-networks.com)（admon-networks.com）の公開インフラを、Terraform で管理するリポジトリです。

## 構成

| ディレクトリ | 内容 | CI/CD |
| --- | --- | --- |
| `infra/dns/` | ホストゾーンと DNS レコード（ブログ、Google Workspace のメールなど） | 対象 |
| `infra/local-only/domain-registration/` | ドメイン登録の設定（自動更新、移管ロック、WHOIS 非公開） | **対象外** |

- state はディレクトリ（スタック）ごとに、S3 に分けて保存しています。
- `infra/dns/` の中は、レコードの種類ごとにファイルを分けています（`record-a.tf`、`record-mx.tf`、`record-txt.tf`）。

## 作業を始めるとき

### 初めての環境（clone した直後）

```bash
cd infra/dns
vi backend.hcl   # state 用の S3 バケットなどを書く（このファイルはコミットしない）
terraform init -backend-config=backend.hcl
```

### 2回目以降

```bash
git pull
aws sso login --profile <プロファイル名> --use-device-code
export AWS_PROFILE=<プロファイル名>
cd infra/dns
terraform plan
```

## 運用ルール

- 秘密情報（鍵、パスワード、連絡先など）はコミットしない
- `backend.hcl`、`*.tfvars`、state ファイルはコミットしない（`.gitignore` で除外済み）
- `.terraform.lock.hcl` はコミットする（プロバイダのバージョンを揃えるため）
- `infra/local-only/` 以下は、手元の端末でのみ実行する
  - 登録者の連絡先を state に持つため、CI で実行するとログに個人情報が出る
  - plan や state の出力をどこかに貼るときは、連絡先の部分を必ず削除する
- ホストゾーンには `prevent_destroy` を設定し、誤って削除できないようにしている
- apply の前には必ず plan を確認し、`destroy` や意図しない変更がないことを確かめる

## DNS の注意点

- 同じ名前の TXT レコードは1つのリソースにまとめる（Route 53 では同じ名前・同じ種類のレコードを2つ作れないため）
- SPF（`v=spf1` で始まる値）は1つまで。送信元を増やすときは、同じ行の中に追記する
- Google Workspace の所有権確認の TXT は、Search Console の確認にも使われているので消さない
- DMARC は `p=none` で運用中。レポートで問題がないことを確認してから、`p=quarantine` に上げる

## 残タスク

### DNS（このリポジトリ）

- [ ] TTL を 300 から 3600 に上げる（1週間ほど問題がなければ。目安：2026-10-04 以降）
- [ ] DMARC のレポートを確認し、問題がなければ `p=none` から `p=quarantine` に上げる

### CI/CD とセキュリティ

- [ ] GitHub Actions で `terraform fmt` と `terraform validate` を自動実行する
  - `infra/local-only/` 以下は対象外にする
  - AWS への認証は、アクセスキーではなく OIDC を使う
- [ ] GitHub のシークレットスキャンとプッシュ保護を有効にする
- [ ] コミット前に gitleaks でチェックする仕組み（pre-commit）を入れる

### 今後の拡張

- [ ] `admon-networks.com`（ルート）のトップページを S3 + CloudFront で作り、`infra/top/` で管理する
- [ ] ブログのサーバーを作り直し（Lightsail の Debian + Ansible）、`infra/blog/` で管理する
- [ ] ブログの画像を S3 に移す
