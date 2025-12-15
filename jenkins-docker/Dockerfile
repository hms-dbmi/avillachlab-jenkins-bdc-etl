# Base Jenkins controller
FROM jenkins/jenkins:lts-jdk21

USER root

# ---- OS utilities commonly needed in pipelines ----
RUN apt-get update && apt-get install -y \
    git \
    jq \
    unzip \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    bash \
    csvkit \
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
RUN tfenv install 0.12.31
RUN tfenv install latest
RUN tfenv use 0.12.31

# ---- Jenkins plugins ----
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# ---- Sanity checks ----
RUN terraform version \
 && aws --version \
 && git --version \
 && jq --version \
 && tfenv --version \
 && csvcut --version

USER jenkins
