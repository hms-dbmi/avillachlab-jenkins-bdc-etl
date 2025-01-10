FROM jenkins/jenkins:2.448

ARG S3_BUCKET

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

COPY config.xml /var/jenkins_home/config.xml

COPY scriptApproval.xml /var/jenkins_home/scriptApproval.xml

COPY hudson.tasks.Maven.xml /var/jenkins_home/hudson.tasks.Maven.xml

USER root

RUN echo "s/stack_s3_bucket_var/$S3_BUCKET/"

RUN sed -i "s/stack_s3_bucket_var/$S3_BUCKET/" /var/jenkins_home/config.xml

RUN apt-get update -y

RUN apt-get -y install apt-transport-https \
    python3-pip \
    wget

RUN pip3 install --no-input awscli --upgrade --break-system-packages

RUN curl -fsSL https://get.docker.com | sh

RUN docker --version

RUN wget https://downloads.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz -P /opt

#RUN apt-get -y -t stretch-backports install openjdk-11-jdk

RUN tar -xvzf /opt/apache-maven-3.8.8-bin.tar.gz -C /opt

RUN rm /opt/apache-maven-3.8.8-bin.tar.gz

RUN apt-get install jq -y

RUN /bin/jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt || echo "Some errors occurred during plugin installation."

RUN wget https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip && unzip terraform_0.12.31_linux_amd64.zip && mv terraform /usr/local/bin/
