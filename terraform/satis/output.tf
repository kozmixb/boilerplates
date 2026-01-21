output "ecr_repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "deployer_role_name" {
  value = aws_iam_role.this.name
}
