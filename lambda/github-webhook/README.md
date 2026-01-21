# Github Slack Webhook

This webhook is designed to consume Github `release` webhooks convert them into slack webhook messages

This is a simple Lambda function behind an AWS API Gateway

## Requirements

- python 3.13 or newer

## To test locally

Run the following script which should pre-populate the required environment variables

```shell
source ./setup.sh
```

After this can run the `Test.py` script which should mimic a test payload for the script
