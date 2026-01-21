#!/bin/bash

if [[ -z ${AWS_REGION} ]] || [[ -z ${AWS_VAULT_NAME} ]]; then
    echo "Please set the following environment variables: "
    echo "AWS_REGION"
    echo "AWS_VAULT_NAME"
    exit 1
fi

aws glacier initiate-job \
  --account-id - \
  --vault-name ${AWS_VAULT_NAME}  \
  --job-parameters '{"Type": "inventory-retrieval"}' \
  --region ${AWS_REGION}
