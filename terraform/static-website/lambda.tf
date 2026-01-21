resource "aws_cloudfront_function" "nextjs" {
  count = var.is_nextjs_app ? 1 : 0

  name    = "rewrite-uri-${replace(var.project_name, " ", "-")}"
  runtime = "cloudfront-js-2.0"
  comment = "Implement dynamic routes for ${var.project_name}"
  publish = true
  code    = file("${path.module}/nextjs.js")
}
