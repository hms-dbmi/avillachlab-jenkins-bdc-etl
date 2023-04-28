# avillachlab-jenkins-bdc-etl
Overview:
This repo stores the etl pipelines that are orchestrated via a Jenkins Continuous Integration Environment.  This readme will contain information on how to setup an initial environment.  Once an initial environment is installed jenkins is able to replicate itself to perform infrastructure and security updates.

Prerequisites:
An EC2 with following configuration.  Contact an admin for appropriate role and ids that are needed:
* IAM Role
* VPC ID
* SUBNET ID
* AMI ID

-----------------------------------------------------
To deploy an initial jenkins phenotypic etl server by performing the following steps.  Terraform variables in the code below should be replaced with the values acquired in the prereqs.

* Connect to a terminal in the ec2 via ssm.  
* git clone https://github.com/hms-dbmi/avillachlab-jenkins-bdc-etl
* follow bash commands.
```
cd dev-jenkins-terraform
env > env.txt
terraform init
terraform apply -auto-approve \
-var "git-commit=__GIT_COMMIT_FOR_JENKINS_ETL_REPO__" \
-var "stack-id=__S3_BUCKET_NAME_SUFFIX__" \
-var "subnet-id=__JENKINS_SUBNET_ID__" \
-var "vpc-id=__JENKINS_VPC_ID__" \
-var "instance-profile-name=__JENKINS_INSTANCE_PROFILE_NAME__" \
-var "access-cidr=__JENKINS_ACCESS_CIDR__" \
-var "provisioning-cidr=__JENKINS_PROVISIONING_CIDR__"


aws s3 --sse=AES256 cp terraform.tfstate s3://${stack_s3_bucket}/jenkins_state_${GIT_COMMIT}/terraform.tfstate 
aws s3 --sse=AES256 cp env.txt s3://${stack_s3_bucket}/jenkins_state_${GIT_COMMIT}/last_env.txt

INSTANCE_ID=`terraform state show aws_instance.dev-jenkins | grep "\"i-[a-f0-9]" | cut -f 2 -d "=" | sed 's/"//g'`

while [ -z $(/usr/local/bin/aws --region=us-east-1 ec2 describe-tags --filters "Name=resource-id,Values=${INSTANCE_ID}" | grep InitComplete) ];do echo "still initializing";sleep 10;done

echo "http://`terraform state show aws_instance.dev-jenkins | grep private_ip | cut -f 2 -d "=" | sed 's/\"//g' | sed 's/ //g'`"
```
-----------------------------------------------------

Once the jenkins server has been created you can connect to it via OKTA. 


   