#!/bin/bash

if [ -z "$(docker images -q terraform-builder:latest 2> /dev/null)" ]; then
  docker build -t 'terraform-builder' .
fi

docker run --rm -it -v .:/app terraform-builder
