output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "security_group_ids" {
  description = "List of security group IDs associated with the EC2 instance"
  value       = aws_instance.this.security_group_names
}

# Output for the latest AMI
output "latest_ami_id" {
  value = data.aws_ami.this.id
}

output "latest_ami_name" {
  value = data.aws_ami.this.name
}

output "latest_ami_description" {
  value = data.aws_ami.this.description
}

output "latest_ami_creation_date" {
  value = data.aws_ami.this.creation_date
}