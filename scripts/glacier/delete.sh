#!/bin/bash

file='./output.json'
if [[ -z ${AWS_REGION} ]] || [[ -z ${AWS_VAULT_NAME} ]]; then
    echo "Please set the following environment variables: "
    echo "AWS_REGION"
    echo "AWS_VAULT_NAME"
    exit 1
fi

jq -r .ArchiveList[].ArchiveId < $file | xargs -P8 -n1 bash -c "echo \"Deleting: \$1\"; aws glacier delete-archive --archive-id=\$1 --vault-name ${AWS_VAULT_NAME} --account-id - --region ${AWS_REGION}" {}
