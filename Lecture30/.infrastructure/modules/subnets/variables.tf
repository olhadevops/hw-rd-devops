variable "vpc_id" {
  description = "The ID of the VPC to associate subnets with"
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
}

variable "project_name" {
  description = "Name of the project for tagging"
  type        = string
}
