data "template_file" "jenkins-user_data" {
  template = file("install-docker.sh")
  vars = {
    stack_s3_bucket = var.stack-s3-bucket
    stack_id = var.stack-id
    stack_jenkins_dockerfile = var.stack-jenkins-dockerfile
  }
}


data "template_file" "jenkins-config-xml" {
  template = file("../jenkins-docker/${var.config-xml-filename}")
  vars = {
    stack_s3_bucket = var.stack-s3-bucket
    jenkins_role_admin_name = var.jenkins-role-admin-name
  }
}
   

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.jenkins-user_data.rendered
  }
}

resource "aws_instance" "dev-jenkins" {
  ami = var.cis-centos-linux-ami-id
  instance_type = "m5.2xlarge"
  associate_public_ip_address = true

  iam_instance_profile = var.instance-profile-name

  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 1000
  }



  provisioner "file" {
    source      = "../jenkins-docker"
    destination = "/home/centos/jenkins"
    connection {
      type     = "ssh"
      user     = "centos"
      host = self.private_ip
    }
  }

  provisioner "file" {
    content = data.template_file.jenkins-config-xml.rendered
    destination = "/home/centos/jenkins/config.xml"
    connection {
      type     = "ssh"
      user     = "centos"
      host = self.private_ip
    }
  }

  vpc_security_group_ids = [
    aws_security_group.inbound-jenkins-from-lma.id,
    aws_security_group.outbound-jenkins-to-internet.id
  ]

  subnet_id = var.subnet-id

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "Jenkins Phenotypic ETL Server - ${var.stack-id} - ${var.git-commit}"
  }

  user_data = data.template_cloudinit_config.config.rendered

}
