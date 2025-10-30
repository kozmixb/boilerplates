#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
terraform fmt -diff -recursive
tflint --recursive --config "$SCRIPTPATH/.tflint.hcl"
