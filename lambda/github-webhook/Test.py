#!/usr/bin/env python3

import Lambda
import json

with open('publish.min.json', 'r') as file:
    payload = json.load(file)
    file.close()


# # payload = {
# #     'body': json.dumps(body),
# #     'headers': {}
# # }
#
# payload['body'] = json.dumps(payload['body'])
response = Lambda.lambda_handler(payload, '')
print(response)
