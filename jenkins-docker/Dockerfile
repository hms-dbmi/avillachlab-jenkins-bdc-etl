FROM jenkins/jenkins:latest-jdk17

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

ARG TERRAFORM_DISTRO
ARG PLUGINS_FILE
ARG CONFIG_XML_FILE
ARG CASC_FILE
ARG SCRIPT_APPROVAL_FILE
ARG HUDSON_TASKS_FILE
ARG JOBS_DIR
ARG PKCS12_FILE
ARG PKCS12_PASS
ARG HTTP_PORT=80
ARG HTTPS_PORT=8080

USER root

RUN apt-get update -y && \
    apt-get install -y \
    apt-transport-https \
    wget \
    jq \
    maven && \
    curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws && \
    curl -fsSL https://get.docker.com | sh && \
    docker --version && \
    wget -q -O /opt/terraform.zip $TERRAFORM_DISTRO && \
    unzip /opt/terraform.zip -d /usr/local/bin/ && \
    rm -f /opt/terraform.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/*

USER jenkins

RUN mkdir -p /var/jenkins_home

COPY $PLUGINS_FILE /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

COPY $CASC_FILE /var/jenkins_home/
COPY $CONFIG_XML_FILE /var/jenkins_home/config.xml
COPY $SCRIPT_APPROVAL_FILE /var/jenkins_home/scriptApproval.xml
COPY $HUDSON_TASKS_FILE /var/jenkins_home/hudson.tasks.Maven.xml
COPY $JOBS_DIR /var/jenkins_home/jobs
COPY $PKCS12_FILE /var/jenkins_home/$PKCS12_FILE

USER root
RUN chown -R jenkins:jenkins /var/jenkins_home
USER jenkins

EXPOSE 80 8080