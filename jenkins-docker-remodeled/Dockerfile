FROM jenkins/jenkins:latest-jdk21

# user to swap easily between OS operations and jenkins configuration.
ENV JENKINS_USERNAME=$USER
# Disbale setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

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

# Can use this to swap users back to jenkins user without hardcoding it.  Safe to hardcode swap to root user.
###### OS configs and package installations ########
# We could run these commands and build an image then configure jenkins only in this dockerfile instead of directly using the jenkins stock image
USER root

RUN apt-get update

RUN apt-get -y install apt-transport-https \
    python3-pip \
    wget

# maybe not the best way to install awscli
# see https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
#RUN pip3 install --no-input awscli --upgrade
RUN pip3 install --no-input awscli --upgrade --break-system-packages

RUN set -e; \
    curl -fsSL https://get.docker.com | sh && \
    docker --version

# maven
RUN apt-get -y install maven
# jq
RUN apt-get install jq -y
# terraform installations
RUN wget -c $TERRAFORM_DISTRO -O /opt/terraform.zip && \
    unzip /opt/terraform.zip -d /usr/local/bin/ && rm -f /opt/terraform.zip

# JDK Installations - Base Image JDK used by jenkins already available.
# JDK 11 made available for update to jdk21 jenkins base image.
RUN apt-get -y install openjdk-11-jdk 

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/*

##### Configuration for jenkins ###########
USER $JENKINS_USERNAME

# Copy CASC file
COPY $CASC_FILE /var/jenkins_home/

# Install Plugins.  If no plugins provided continue.
COPY $PLUGINS_FILE /usr/share/jenkins/ref/plugins.txt

RUN /bin/jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Configurations
COPY $CONFIG_XML_FILE /var/jenkins_home/config.xml
COPY $SCRIPT_APPROVAL_FILE /var/jenkins_home/scriptApproval.xml
COPY $HUDSON_TASKS_FILE /var/jenkins_home/hudson.tasks.Maven.xml
COPY $JOBS_DIR /var/jenkins_home/jobs
COPY $PKCS12_FILE /var/jenkins_home/$PKCS12_FILE
