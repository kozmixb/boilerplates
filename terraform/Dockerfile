# VARIABLES
## https://github.com/hashicorp/terraform/tags
ARG TERRAFORM_VERSION=1.12.2
ARG TERRAFORM_ARCH=amd64
## https://github.com/aws/aws-cli
ARG AWS_CLI_VERSION=2.27.50
## https://github.com/digitalocean/doctl
ARG DOCTL_VERSION=1.131.0

#################################################
# Terrafom CLI
#################################################
FROM debian:latest AS terraform
ARG TERRAFORM_VERSION
ARG TERRAFORM_ARCH

RUN apt update && apt install --no-install-recommends -y \
    ca-certificates \
    curl \
    gnupg \
    unzip

WORKDIR /app

RUN curl --silent --show-error --fail --output "terraform.zip" --remote-name "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TERRAFORM_ARCH}.zip" && \
    unzip -j terraform.zip

RUN curl -L --silent --show-error --fail --output "tflint.zip" --remote-name "https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_${TERRAFORM_ARCH}.zip" && \
    unzip tflint.zip

#################################################
# AWS CLI V2
#################################################
FROM debian:latest AS aws
ARG AWS_CLI_VERSION
RUN apt update && apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    unzip

WORKDIR /app

RUN curl --show-error --fail --output "awscliv2.zip" --remote-name "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" && \
    unzip -u awscliv2.zip && \
    ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin

RUN curl -L --show-error --fail --output "eksctl.tar.gz" --remote-name "https://github.com/eksctl-io/eksctl/releases/download/v0.210.0/eksctl_Linux_amd64.tar.gz" && \
    tar -xzf eksctl.tar.gz

#################################################
# DigidalOcean CLI
#################################################
FROM debian:latest AS digitalocean
ARG DOCTL_VERSION
RUN apt update && apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    unzip

WORKDIR /app

RUN curl -L --show-error --fail --output "doctl.tar.gz" --remote-name "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz" && \
    tar xf doctl.tar.gz && \
    mv doctl /usr/local/bin

#################################################
# Build image
#################################################
FROM debian:latest AS build
RUN apt update && apt install -y --no-install-recommends \
    ca-certificates\
    git \
    jq \
    openssh-server \
    less \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=terraform /app/terraform /usr/local/bin/terraform
COPY --from=aws /usr/local/bin/ /usr/local/bin/
COPY --from=terraform /app/tflint /usr/local/bin/tflint
COPY --from=aws /app/eksctl /usr/local/bin/eksctl
COPY --from=aws /usr/local/aws-cli /usr/local/aws-cli
COPY --from=digitalocean /usr/local/bin/ /usr/local/bin/

CMD ["bash"]
