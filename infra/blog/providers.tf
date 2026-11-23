# 全リソースに共通で付けるタグ
locals {
  common_tags = {
    ManagedBy  = "terraform"
    Project    = "admon-networks"
    Repository = "admon-networks/public-infra"
    Stack      = "blog"
  }
}

# 本番アカウント（S3・CloudFront など）
provider "aws" {
  region  = "ap-northeast-1"
  profile = var.aws_profile

  default_tags {
    tags = local.common_tags
  }
}

# 本番アカウントの us-east-1（CloudFront に付ける ACM 証明書はこのリージョンに作る決まり）
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile

  default_tags {
    tags = local.common_tags
  }
}

# 管理アカウント（Route 53 のホストゾーンがあるため、証明書の検証用レコードはここに作る）
provider "aws" {
  alias   = "dns"
  region  = "ap-northeast-1"
  profile = var.dns_aws_profile

  default_tags {
    tags = local.common_tags
  }
}
