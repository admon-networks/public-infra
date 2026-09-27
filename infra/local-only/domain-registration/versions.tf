terraform {
  # このコードを実行できる Terraform のバージョン
  required_version = ">= 1.10"

  # 使うプロバイダとバージョン
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # state の保存先。具体的な値は backend.hcl から渡す
  backend "s3" {}
}
