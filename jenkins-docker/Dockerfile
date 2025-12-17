# Base Jenkins controller
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

# ---- Docker CLI + Compose v2 plugin (client only; uses host docker.sock) ----
# Use bookworm repo for docker packages
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
  . /etc/os-release; \
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

# ---- AWS CLI v2 ----
RUN set -eux; \
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
  && unzip /tmp/awscliv2.zip -d /tmp \
  && /tmp/aws/install \
  && rm -rf /tmp/aws /tmp/awscliv2.zip

# ---- tfenv (Terraform version manager) ----
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git /opt/tfenv \
 && ln -s /opt/tfenv/bin/* /usr/local/bin

# ---- Install Terraform versions ----
RUN tfenv install 0.12.31 \
 && tfenv install latest \
 && tfenv use 0.12.31

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