#Lookup latest AMI
data "aws_ami" "this" {
  most_recent = true
  name_regex  = var.ami_regex
  owners      = var.ami_owners
}

resource "aws_iam_instance_profile" "this" {
  name = var.instance_profile_name
  role = var.instance_profile_role
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.this.id
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address # We should look into removing this public interface.
  iam_instance_profile        = aws_iam_instance_profile.this.name

  # I want to explore using EBS attached devices. This would eliminate a static non-detachable block device.
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = var.volume_size
  }


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

  user_data = data.template_cloudinit_config.this.rendered
}

data "template_file" "this" {
  template = file(var.user_script)

  vars = {
    stack_s3_bucket = var.stack_s3_bucket
  }
}

data "template_cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.this.rendered
  }
}

resource "aws_security_group" "inbound" {
  name        = "jenkins_inbound_${local.uniq_name}"
  description = "Allow inbound traffic from private network on ports 22, 80 and 443"
  vpc_id      = var.vpc_id

  # need to d
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      var.access_cidr
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.access_cidr

    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      var.access_cidr
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
  }
}

resource "aws_security_group" "outbound" {
  name        = "jenkins_outbound_${local.uniq_name}"
  description = "Allow outbound traffic from Jenkins"
  vpc_id      = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
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