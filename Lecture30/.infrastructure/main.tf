provider "aws" {
  region = var.aws_region
}

// Resource: Common Security Group for EC2 instances
// This SG is created once at the root level and then passed to both EC2 modules.
resource "aws_security_group" "common_ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Common Security Group for EC2 instances allowing SSH and HTTP"
  vpc_id      = module.vpc.vpc_id # Reference the VPC created by the VPC module

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  vpc_name     = var.project_name
}

module "subnets" {
  source                 = "./modules/subnets"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  availability_zone      = var.aws_availability_zone
  project_name           = var.project_name
}

module "public_ec2" {
  source          = "./modules/ec2"
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.subnets.public_subnet_id
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  instance_name   = "${var.project_name}-public-server"
  project_name    = var.project_name
  key_pair_name   = var.key_pair_name
  security_group_id = aws_security_group.common_ec2_sg.id
}

module "private_ec2" {
  source          = "./modules/ec2"
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.subnets.private_subnet_id
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  instance_name   = "${var.project_name}-private-server"
  project_name    = var.project_name
  key_pair_name   = var.key_pair_name
  security_group_id = aws_security_group.common_ec2_sg.id
}

resource "aws_security_group" "manual_sg_imported" {
  name        = "ManualSecurityGroup"
  description = "ManualSecurityGroup created 2025-06-26T22:28:39.410Z"
  vpc_id      = module.vpc.vpc_id # Reference the VPC created by the VPC module

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }

  tags = {}
}

resource "aws_instance" "manual_ec2_imported" {
   ami                                  = "ami-00c8ac9147e19828e"
   instance_type                        = "t3.micro"
   subnet_id                            = "subnet-097518655e9a2edf1"
   vpc_security_group_ids               = [aws_security_group.manual_sg_imported.id]
   key_name                             = "dev-key"
   tags = {
     Name = "ManualWebServer"
   }
}
