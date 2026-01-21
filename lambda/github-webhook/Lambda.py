import os
import urllib3
import json
import re
import hmac
import hashlib

def generate_payload(event):
    return json.dumps({
        "blocks": [
            {
                "type": "header",
                "text": {
                   "type": "plain_text",
                   "text": f":rocket: {event['repository']['name']} : {event['release']['tag_name']}",
                }
            },
            {
                "type": "context",
                "elements": [
                   {
                       "type": "mrkdwn",
                       "text": f"*Github:* <{event['repository']['html_url']}|{event['repository']['full_name']}>"
                   }
                ]
            },
            {
                "type": "context",
                "elements": [
                   {
                       "type": "mrkdwn",
                       "text": f"*Version:* <{event['release']['html_url']}|{event['release']['tag_name']}>"
                   }
                ]
            },
            {
                "type": "context",
                "elements": [
                   {
                       "type": "mrkdwn",
                       "text": f"*Publisher:* <{event['release']['author']['html_url']}|{event['release']['author']['login']}>"
                   }
                ]
            },
            {
                "type": "divider"
            },
            {
                "type": "section",
                "text": {
                   "type": "mrkdwn",
                   "text": event['release']['body'][0 : 1000]
                }
            }
        ]
    })

def send_message(event):
    SLACK_URL = os.environ.get('SLACK_WEBHOOK_URL')

    if not SLACK_URL:
        return {
            'statusCode': 500,
            'body': 'INVALID CONFIG'
        }

    json_payload = generate_payload(event)
    print(json_payload)

    try:
        http = urllib3.PoolManager()
        response = http.request('POST', SLACK_URL, body=json_payload, headers={"Content-Type":"application/json", "Accept": "application/json"})
        print('Successful slack call')
        print(response.data)
        return {
            'statusCode': response.status,
            'body': 'OK'
        }
    except Exception as e:
        print(e)

    return {
        'statusCode': 500,
        'body': 'Failed'
    }


def verify_signature(payload_body, secret_token, signature_header):
    if not signature_header:
        raise Exception("x-hub-signature-256 header is missing!")
    hash_object = hmac.new(secret_token.encode('utf-8'), msg=payload_body.encode('utf-8'), digestmod=hashlib.sha256)
    expected_signature = "sha256=" + hash_object.hexdigest()

    print(expected_signature)
    print(signature_header)
    if not hmac.compare_digest(expected_signature, signature_header):
        raise Exception("Request signatures didn't match!")

    print('Signature verified')


def lambda_handler(event, context):
    verify_signature(event['body'], os.environ['WEBHOOK_SECRET'], event['headers'].get('X-Hub-Signature-256'))
    body = json.loads(event['body'])

    print(body)
    if 'action' not in body:
        print('Action is missing')
        return {
            'statusCode': 400,
            'body': 'MISSING ACTION'
        }

    if body.get('action') != 'published':
        print('Action is not published')
        return {
            'statusCode': 400,
            'body': 'INVALID ACTION'
        }

    return send_message(body)
