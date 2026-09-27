# 全リソースに共通で付けるタグ
locals {
  common_tags = {
    ManagedBy  = "terraform"
    Project    = "admon-networks"
    Repository = "admon-networks/public-infra"
    Stack      = "dns"
  }
}

# 通常のリソース（ホストゾーンなど）用
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = local.common_tags
  }
}

# ドメイン登録（Route 53 Domains）用。この API は us-east-1 にしかない
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
