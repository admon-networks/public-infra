locals {
  common_tags = {
    ManagedBy  = "terraform"
    Project    = "admon-networks"
    Repository = "admon-networks/public-infra"
    Stack      = "domain-registration"
  }
}

# Route 53 Domains の API は us-east-1 にしかない
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
