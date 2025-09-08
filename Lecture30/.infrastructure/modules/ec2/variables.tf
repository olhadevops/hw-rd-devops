variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "project_name" {
  description = "Name of the project for tagging"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to attach to the EC2 instance"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the AWS key pair to use for SSH access"
  type        = string
}
