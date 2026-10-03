
output "deploy_role_arn" {
  description = "GitHub Actions の Variables に登録するロール ARN"
  value       = module.deploy_role.role_arn
}
