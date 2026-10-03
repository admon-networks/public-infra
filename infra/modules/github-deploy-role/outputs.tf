
output "role_arn" {
  description = "作成した IAM ロールの ARN（GitHub Actions に設定する）"
  value       = aws_iam_role.this.arn
}
