# syntax=docker/dockerfile:1

FROM jenkins/jenkins:lts-jdk21

USER root

# ---- OS utilities commonly needed in pipelines ----
RUN apt-get update && apt-get install -y \
    git jq unzip curl ca-certificates gnupg lsb-release bash \
 && rm -rf /var/lib/apt/lists/*

# ---- AWS CLI v2 (multi-arch: amd64/arm64) ----
ARG TARGETARCH
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64)  AWS_ARCH="x86_64" ;; \
    arm64)  AWS_ARCH="aarch64" ;; \
    *) echo "Unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o /tmp/awscliv2.zip; \
  unzip /tmp/awscliv2.zip -d /tmp; \
  /tmp/aws/install; \
  rm -rf /tmp/aws /tmp/awscliv2.zip

# ---- tfenv (Terraform version manager) ----
ENV TFENV_ROOT=/usr/local/tfenv
ENV TFENV_AUTO_INSTALL=true

RUN git clone --depth=1 https://github.com/tfutils/tfenv.git "$TFENV_ROOT" \
 && ln -s "$TFENV_ROOT/bin/"* /usr/local/bin/ \
 && mkdir -p "$TFENV_ROOT/versions" \
 && chown -R jenkins:jenkins "$TFENV_ROOT"

# ---- (Optional) Preinstall multiple Terraform versions (modern) ----
# Override at build time, e.g.:
#   --build-arg TERRAFORM_VERSIONS="1.5.7 1.6.6 1.7.5 1.8.5 1.9.8"
# Also choose a default with TERRAFORM_DEFAULT.
ARG TERRAFORM_VERSIONS="1.6.6 1.7.5 1.8.5 1.9.8"
ARG TERRAFORM_DEFAULT="1.9.8"
RUN set -eux; \
  for v in ${TERRAFORM_VERSIONS}; do \
    tfenv install "$v"; \
  done; \
  tfenv use "${TERRAFORM_DEFAULT}"

# ---- Jenkins plugins ----
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# ---- Sanity checks ----
RUN terraform version \
 && aws --version \
 && git --version \
 && jq --version \
 && tfenv --version

USER jenkins
