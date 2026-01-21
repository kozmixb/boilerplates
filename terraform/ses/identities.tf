resource "aws_sesv2_email_identity" "this" {
  for_each = toset(var.identities)

  email_identity         = each.value
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name
}

resource "aws_sesv2_email_identity_feedback_attributes" "this" {
  for_each = aws_sesv2_email_identity.this

  email_identity           = each.value.email_identity
  email_forwarding_enabled = true
}
