resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  url = var.github_oidc_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  # Output of the following script
  # echo | openssl s_client -connect token.actions.githubusercontent.com:443 2>&- | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}'
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}
