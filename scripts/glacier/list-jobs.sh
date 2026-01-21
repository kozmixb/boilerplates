#!/bin/bash

if [[ -z ${AWS_REGION} ]] || [[ -z ${AWS_VAULT_NAME} ]]; then
    echo "Please set the following environment variables: "
    echo "AWS_REGION"
    echo "AWS_VAULT_NAME"
    exit 1
fi

aws glacier list-jobs \
  --account-id - \
  --vault-name ${AWS_VAULT_NAME} \
  --region ${AWS_REGION}
