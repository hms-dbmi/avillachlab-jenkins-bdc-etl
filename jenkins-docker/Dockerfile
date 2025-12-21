# syntax=docker/dockerfile:1

FROM jenkins/jenkins:lts-jdk21

USER root

# --- Ensure Debian repos exist (fix "Unable to locate package" on trixie-based images) ---
RUN set -eux; \
  . /etc/os-release; \
  install -m 0755 -d /etc/apt/keyrings; \
  cat >/etc/apt/sources.list.d/debian.sources <<EOF
Types: deb
URIs: http://deb.debian.org/debian
Suites: ${VERSION_CODENAME}
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://deb.debian.org/debian
Suites: ${VERSION_CODENAME}-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://security.debian.org/debian-security
Suites: ${VERSION_CODENAME}-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# ---- Docker CLI + Compose v2 plugin ----
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends ca-certificates curl gnupg; \
  install -m 0755 -d /etc/apt/keyrings; \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
  chmod a+r /etc/apt/keyrings/docker.gpg; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" \
    > /etc/apt/sources.list.d/docker.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin; \
  rm -rf /var/lib/apt/lists/*

# ---- Adoptium (Temurin) apt repo ----
RUN set -eux; \
  install -m 0755 -d /etc/apt/keyrings; \
  curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg; \
  echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" \
    > /etc/apt/sources.list.d/adoptium.list

# ---- OS utilities + Tools ----
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    git jq unzip zip curl ca-certificates gnupg lsb-release bash \
    csvkit \
    postgresql-client \
    python3 python3-venv python3-pip \
    temurin-11-jdk temurin-17-jdk temurin-21-jdk temurin-24-jdk \
  ; \
  rm -rf /var/lib/apt/lists/*

# ---- AWS CLI v2 (multi-arch) ----
ARG TARGETARCH
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64) AWS_ARCH="x86_64" ;; \
    arm64) AWS_ARCH="aarch64" ;; \
    *) echo "Unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o /tmp/awscliv2.zip; \
  unzip /tmp/awscliv2.zip -d /tmp; \
  /tmp/aws/install; \
  rm -rf /tmp/aws /tmp/awscliv2.zip

# ---- tfenv (Terraform version manager) ----
ENV TFENV_ROOT=/usr/local/tfenv
ENV TFENV_AUTO_INSTALL=true

RUN set -eux; \
  git clone --depth=1 https://github.com/tfutils/tfenv.git "$TFENV_ROOT"; \
  ln -s "$TFENV_ROOT/bin/"* /usr/local/bin/; \
  mkdir -p "$TFENV_ROOT/versions"; \
  chown -R jenkins:jenkins "$TFENV_ROOT"

# ---- Default Terraform = latest ----
RUN set -eux; \
  tfenv install latest; \
  tfenv use latest

# ---- Jenkins plugins ----
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# ---- Sanity checks ----
RUN set -eux; \
  java -version; \
  psql --version; \
  aws --version; \
  terraform version; \
  git --version; \
  jq --version; \
  tfenv --version; \
  csvcut --version; \
  docker --version

USER jenkins
