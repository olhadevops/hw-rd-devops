output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.subnets.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = module.subnets.private_subnet_id
}

output "public_server_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = module.public_ec2.public_ip
}

output "private_server_private_ip" {
  description = "Private IP of the private EC2 instance"
  value       = module.private_ec2.private_ip
}
