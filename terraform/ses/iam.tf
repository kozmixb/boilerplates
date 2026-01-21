data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "this" {
  name   = "AWSSendEmailPolicy"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_group" "this" {
  name = "AWSSESSendingGroupDoNotRename"
}

resource "aws_iam_group_policy_attachment" "this" {
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.this.arn
}
