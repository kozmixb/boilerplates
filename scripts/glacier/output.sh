#!/bin/bash

if [[ -z ${AWS_REGION} ]] || [[ -z ${AWS_VAULT_NAME} ]] || [[ -z ${JOB_ID} ]]; then
    echo "Please set the following environment variables: "
    echo "AWS_REGION"
    echo "AWS_VAULT_NAME"
    echo "JOB_ID"
    exit 1
fi

aws glacier get-job-output \
  --account-id - \
  --region ${AWS_REGION} \
  --vault-name ${AWS_VAULT_NAME} \
  --job-id ${JOB_ID} \
  ./output.json
