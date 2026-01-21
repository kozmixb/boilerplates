output "keda_role_arn" {
  value = aws_iam_role.cloudwatch_agent.arn
}

output "keda_role_name" {
  value = aws_iam_role.cloudwatch_agent.name
}
