# Base Jenkins controller
FROM jenkins/jenkins:lts-jdk21

USER root

# ---- OS utilities commonly needed in pipelines ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    jq \
    unzip \
    zip \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    bash \
    csvkit \
 && rm -rf /var/lib/apt/lists/*
 
# ---- Python (venv + pip support for Jenkins jobs) ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*
 
# ---- Docker CLI + Compose v2 plugin (client only; uses host docker.sock) ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
 && chmod a+r /etc/apt/keyrings/docker.gpg \
 && . /etc/os-release \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian $VERSION_CODENAME stable" \
    > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    docker-ce-cli \
    docker-compose-plugin \
 && rm -rf /var/lib/apt/lists/*

# ---- Adoptium (Temurin) apt repo ----
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
    | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(. /etc/os-release && echo $VERSION_CODENAME) main" \
    > /etc/apt/sources.list.d/adoptium.list

# ---- Install Temurin JDKs ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    temurin-11-jdk \
    temurin-17-jdk \
    temurin-21-jdk \
    temurin-24-jdk \
 && rm -rf /var/lib/apt/lists/*

# ---- AWS CLI v2 ----
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
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
RUN java -version \
 && ls -la /usr/lib/jvm \
 && aws --version \
 && terraform version \
 && git --version \
 && jq --version \
 && tfenv --version \
 && csvcut --version \
 && docker --version

USER jenkins

