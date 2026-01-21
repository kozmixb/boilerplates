output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_aliases" {
  value = aws_cloudfront_distribution.this.aliases
}

output "s3_origin_id" {
  value = one(aws_cloudfront_distribution.this.origin[*].origin_id)
}

output "github_deployer_role" {
  value = aws_iam_role.this.name
}

