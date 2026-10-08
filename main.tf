terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# =========================
# AWS PROVIDER
# =========================

provider "aws" {
  region = var.aws_region
}


# =========================
# VPC
# =========================

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops-vpc"
  }
}


# =========================
# PUBLIC SUBNET
# =========================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-public-subnet"
  }
}


# =========================
# INTERNET GATEWAY
# =========================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-internet-gateway"
  }
}


# =========================
# PUBLIC ROUTE TABLE
# =========================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "devops-public-route"
  }
}


# =========================
# ROUTE TABLE ASSOCIATION
# =========================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# =========================
# SECURITY GROUP
# =========================

resource "aws_security_group" "web" {
  name        = "devops-web-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id

  # -------------------------
  # SSH - Port 22
  # -------------------------

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -------------------------
  # HTTP - Port 80
  # -------------------------

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -------------------------
  # OUTBOUND TRAFFIC
  # -------------------------

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-web-sg"
  }
}


# =========================
# EC2 INSTANCE
# =========================

resource "aws_instance" "web" {

  # AMI comes from terraform.tfvars
  ami = var.ami_id

  # EC2 instance type
  instance_type = "t3.micro"

  # Put EC2 inside our public subnet
  subnet_id = aws_subnet.public.id

  # Attach security group
  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  # Give EC2 a public IP
  associate_public_ip_address = true

  # EC2 key pair
  key_name = var.key_name


  # =========================
  # USER DATA
  # INSTALL DOCKER AUTOMATICALLY
  # =========================

  user_data = <<-EOF
              #!/bin/bash

              # Update Amazon Linux
              dnf update -y

              # Install Docker
              dnf install -y docker

              # Start Docker
              systemctl start docker

              # Start Docker automatically after reboot
              systemctl enable docker

              # Allow ec2-user to use Docker
              usermod -aG docker ec2-user
              EOF


  # =========================
  # EC2 TAG
  # =========================

  tags = {
    Name = "devops-web-server"
  }
}
