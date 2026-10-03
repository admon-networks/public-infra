# 全リソースに共通で付けるタグ
locals {
  common_tags = {
    ManagedBy  = "terraform"
    Project    = "admon-networks"
    Repository = "admon-networks/public-infra"
    Stack      = "github-oidc"
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = local.common_tags
  }
}
