output "github_actions_oidc_provider_arn" {
  description = "GitHub Actions 用 OIDC プロバイダーの ARN"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}
