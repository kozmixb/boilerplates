resource "aws_sns_topic" "this" {
  name = "ses-email-bounce-back"
}

resource "aws_sesv2_configuration_set" "this" {
  configuration_set_name = "default-config"

  delivery_options {
    max_delivery_seconds = 300
    tls_policy           = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = false
  }

  sending_options {
    sending_enabled = true
  }
}

resource "aws_sesv2_configuration_set_event_destination" "sns" {
  event_destination_name = "event-destination-sns"
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name

  event_destination {
    enabled              = true
    matching_event_types = ["BOUNCE"]

    sns_destination {
      topic_arn = aws_sns_topic.this.arn
    }
  }
}

resource "aws_sesv2_account_suppression_attributes" "this" {
  suppressed_reasons = ["BOUNCE", "COMPLAINT"]
}
