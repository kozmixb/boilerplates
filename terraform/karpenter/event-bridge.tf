resource "aws_sqs_queue" "karpenter_queue" {
  name                      = "${var.environment}-karpenter-interruption-queue"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_rule" "karpenter_rule" {
  name        = "${title(var.environment)}KarpenterEventBridgeRule"
  description = "Capture EC2 events"

  event_pattern = jsonencode({
    "source" = [
      "aws.ec2"
    ],
    "detail-type" = [
      "EC2 Instance Rebalance Recommendation",
      "EC2 Spot Instance Interruption Warning"
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "karpenter" {
  rule      = aws_cloudwatch_event_rule.karpenter_rule.name
  target_id = "SendToSqs"
  arn       = aws_sqs_queue.karpenter_queue.arn
}

resource "aws_sqs_queue_policy" "karpenter_queue_policy" {
  queue_url = aws_sqs_queue.karpenter_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "sqspolicy"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action   = "sqs:SendMessage",
        Resource = aws_sqs_queue.karpenter_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.karpenter_rule.arn
          }
        }
      }
    ]
  })
}
