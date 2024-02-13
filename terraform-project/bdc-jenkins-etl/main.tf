#Lookup latest AMI
data "aws_ami" "this" {
  most_recent = true
  name_regex  = var.ami_regex
  owners      = var.ami_owners
}

# going to leave the ec2 key pair here for now.  We may want to manage this abstractly as it will constantly rotate the key.
resource "aws_instance" "this" {
  ami = data.aws_ami.this.id
  instance_type = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address # We should look into removing this public interface.
  # key_name = aws_key_pair.generated_key.key_name # lets eliminate the key pair for now.  We do not use it to connect to the instance

  iam_instance_profile = var.instance_profile_name

  # I want to explore using EBS attached devices. This would eliminate a static non-detachable block device.
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = var.volume_size
  }
  # Lets not copy the docker folder to the server.  
  # docker build stuff goes in the docker build job.  all we want the server to do is run our container and any provisioning for volume mounts.
  # provisioner "file" {
  #  source      = "../jenkins-docker"
  #  destination = "/home/centos/jenkins"
  #  connection {
  #    type     = "ssh"
  #    user     = "centos"
  #    private_key = tls_private_key.provisioning-key.private_key_pem
  #    host = self.private_ip
  #  }
  #}

#  provisioner "file" {
#    content = data.template_file.jenkins-config-xml.rendered
#    destination = "/home/centos/jenkins/config.xml"
#    connection {
#      type     = "ssh"
#      user     = "centos"
#      private_key = tls_private_key.provisioning-key.private_key_pem
#      host = self.private_ip
#    }
#  }

  vpc_security_group_ids = [
    aws_security_group.inbound.id,
    aws_security_group.outbound.id
  ]

  subnet_id = var.subnet_id

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "Jenkins Phenotypic ETL Server - ${local.uniq_name}"
  }

  user_data = data.template_cloudinit_config.config.rendered

}

# this is pretty insecure.  We are outputting the private key to an output.  
# removing key pair
#resource "tls_private_key" "provisioning-key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}
#output "provisioning-private-key" {
#  value = tls_private_key.provisioning-key.private_key_pem
#}

# Not going to provision this docker folder to jenkins
# This will no longer be needed.  Was only being created to provision jenkins-docker contents to the server to do some docker configurations.
# Will investigate a KMS solution or a SSM solution to connect securely to the instance
#resource "aws_key_pair" "this" {
#  key_name   = "jenkins-provisioning-key-${var.stack-id}-${var.git-commit}"
#  public_key = tls_private_key.provisioning-key.public_key_openssh
#}

# Need to update this after user-script
data "template_file" "this" {
  template = file(var.user_script)

  vars = {
    stack_s3_bucket = var.stack_s3_bucket
    
  }
}

# I wouldn't render this config file here as it ties it to infrastructure
# We can use terraform to render config files if we want though.
# Externalizing the variables out of the xml file will make them easier to manage as well.
#data "template_file" "jenkins-config-xml" {
#  template = file("../jenkins-docker/${var.config-xml-filename}")
#  vars = {
#    okta_saml_app_id = var.okta-app-id
#    aws_account_app = var.aws-account-app
#    arn_role_app = var.arn-role-app
#    arn_role_cnc = var.arn-role-cnc
#    arn_role_data = var.arn-role-data
#    git_branch_avillachlab_jenkins_dev_release_control = var.git-branch-avillachlab-jenkins-dev-release-control
#    avillachlab_release_control_repo = var.avillachlab-release-control-repo
#    stack_s3_bucket = var.stack_s3_bucket
#    jenkins_role_admin_name = var.jenkins-role-admin-name
#  }
#}  

data "template_cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.jenkins-user_data.rendered
  }
}

resource "aws_security_group" "inbound" {
  name = "jenkins_inbound_${local.uniq_name}"
  description = "Allow inbound traffic from LMA on ports 22, 80 and 443"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      var.access_cidr

    ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      var.access_cidr

    ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      var.access_cidr

    ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      var.provisioning_cidr
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
  }
}

resource "aws_security_group" "outbound" {
  name = "jenkins_outbound_${local.uniq_name}"
  description = "Allow outbound traffic from Jenkins"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [
       "0.0.0.0/0"
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
  }
}

# local vars
resource "random_string" "random" {
  length  = 5
  special = false
}

locals {
  uniq_name = random_string.random.result
}