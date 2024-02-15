#!/bin/bash
# Would not need complicated business logic in an golden ami build.  I should already know what package manager my business needs.  
if ! command -v yum-config-manager &> /dev/null; then
   echo "yum-config-manager is not installed."

   # Check if dnf is installed
   if command -v dnf &> /dev/null; then
      echo "dnf is installed. Installing yum-utils..."
      sudo dnf install -y yum-utils
   else
      echo "dnf is not installed."
   fi
else
   echo "yum-config-manager is already installed."
fi
export awscli_version=v1
# aws cli2 is only distributed as an install for good reason see: https://github.com/aws/aws-cli/issues/4947
# Need to test aws cli2 more.  We will most likely need to change how assume role is performed.
if [ -z $awscli_version ] || [ ${awscli_version} == v1 ]; then
   sudo yum -y install python3-pip
   sudo pip3 install awscli --upgrade --user
elif [ ${awscli_version} == v2 ]; then
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
else
   echo "invalid aws version: $aws_version"
   exit 1
fi

aws --version

# Should be on the base image
# wget, ssm, cloudwatch

echo "user-data progress starting update"
sudo yum -y update 
sudo yum install wget -y
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U amazon-cloudwatch-agent.rpm

# cloudwatch configs should be defined externally instead of in the user-script
sudo touch /opt/aws/amazon-cloudwatch-agent/etc/custom_config.json
echo "
{
	\"metrics\": {
		
		\"metrics_collected\": {
			\"cpu\": {
				\"measurement\": [
					\"cpu_usage_idle\",
					\"cpu_usage_user\",
					\"cpu_usage_system\"
				],
				\"metrics_collection_interval\": 300,
				\"totalcpu\": false
			},
			\"disk\": {
				\"measurement\": [
					\"used_percent\"
				],
				\"metrics_collection_interval\": 600,
				\"resources\": [
					\"*\"
				]
			},
			\"mem\": {
				\"measurement\": [
					\"mem_used_percent\",
                                        \"mem_available\",
                                        \"mem_available_percent\",
                                       \"mem_total\",
                                        \"mem_used\"
                                        
				],
				\"metrics_collection_interval\": 600
			}
		}
	},
	\"logs\":{
   \"logs_collected\":{
      \"files\":{
         \"collect_list\":[
            {
               \"file_path\":\"/var/log/secure\",
               \"log_group_name\":\"secure\",
               \"log_stream_name\":\"{instance_id} secure\",
               \"timestamp_format\":\"UTC\"
            },
            {
               \"file_path\":\"/var/log/messages\",
               \"log_group_name\":\"messages\",
               \"log_stream_name\":\"{instance_id} messages\",
               \"timestamp_format\":\"UTC\"
            },
						{
               \"file_path\":\"/var/log/audit/audit.log\",
               \"log_group_name\":\"audit.log\",
               \"log_stream_name\":\"{instance_id} audit.log\",
               \"timestamp_format\":\"UTC\"
            },
						{
               \"file_path\":\"/var/log/yum.log\",
               \"log_group_name\":\"yum.log\",
               \"log_stream_name\":\"{instance_id} yum.log\",
               \"timestamp_format\":\"UTC\"
            }
         ]
      }
		}
	}


}

" > /opt/aws/amazon-cloudwatch-agent/etc/custom_config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/custom_config.json  -s

echo "user-data progress finished update installing epel-release"

sudo yum -y install epel-release 
echo "user-data progress finished epel-release adding docker-ce repo"
sudo yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo "user-data progress added docker-ce repo starting docker install"
sudo yum -y install docker-ce docker-ce-cli containerd.io
echo "user-data progress finished docker install enabling docker service"
sudo systemctl enable docker
echo "user-data progress finished enabling docker service starting docker"
sudo service docker start

#### Everything above should be in a ami
## Should just need this to get the container running

# grab image tar
aws s3 cp s3://${stack_s3_bucket}/containers/jenkins/jenkins.tar.gz jenkins.tar.gz

# load image
load_result=$(docker load -i jenkins.tar.gz)
image_tag=$(echo "$load_result" | grep -o -E "jenkins:[[:alnum:]_]+")

#run docker container
sudo docker run -d --log-driver syslog --log-opt tag=jenkins \
                    -v /var/jenkins_home/workspace:/var/jenkins_home/workspace \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -p 443:8443 \
                    --restart always \
                    --name jenkins \
                    $image_tag

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true
