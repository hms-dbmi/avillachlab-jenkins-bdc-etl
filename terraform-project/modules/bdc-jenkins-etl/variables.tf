variable "ami_regex" {
  description = "Regular expression to match the AMI name"
  type        = string
}

variable "ami_owners" {
  description = "List of AWS account IDs that own the AMIs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "instance_profile_role" {
  description = "IAM instance role for ec2 IAM profile"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for the EC2 instance"
  type        = string
}

variable "volume_size" {
  description = "Size of the root EBS volume"
  type        = number
}

variable "subnet_id" {
  description = "ID of the subnet in which the EC2 instance will be launched"
  type        = string
}

variable "stack_s3_bucket" {
  description = "S3 bucket for the stack"
  type        = string
}

variable "user_script" {
  description = "Path to the user script file"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "access_cidr" {
  description = "CIDR block for inbound and outbound access"
  type        = string
}

variable "arn_sm_crowdstrike" {
  description = "arn for CrowdStrike secrets"
  type        = string
}

variable "arn_sm_general" {
  description = "arn for general secrets"
  type        = string
}
