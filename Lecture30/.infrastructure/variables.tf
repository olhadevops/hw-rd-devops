variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "aws_availability_zone" {
  description = "AWS Availability Zone"
  type        = string
  default     = "eu-north-1a"
}

variable "project_name" {
  description = "Name for the project"
  type        = string
  default     = "MyTerraformProject"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (e.g., Amazon Linux 2 AMI)"
  type        = string
  # eu-north-1 Amazon Linux 2 AMI: ami-0da6daf5e3e5ea2a8
  default = "ami-0da6daf5e3e5ea2a8"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair to use for SSH access"
  type        = string
  # Create a key pair in AWS
  default     = "dev-key"
}
