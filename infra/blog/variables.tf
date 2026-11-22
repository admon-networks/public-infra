variable "aws_profile" {
  description = "ブログのリソースを作る本番アカウントの AWS CLI プロファイル"
  type        = string
  default     = "admon-prod"
}

variable "dns_aws_profile" {
  description = "Route 53 のホストゾーンがある管理アカウントの AWS CLI プロファイル"
  type        = string
  default     = "homelab"
}

variable "zone_name" {
  description = "ブログのレコードを置くホストゾーン"
  type        = string
  default     = "admon-networks.com"
}

variable "domain_name" {
  description = "ブログのドメイン"
  type        = string
  default     = "blog.admon-networks.com"
}
