# --- provider ---

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" #stay on branch 5 for stability
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC virtual private cloud ---

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# --- Internet gateway ---

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }

}

# --- Subnet ---

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
  }
}

# --- Route table ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# --- Security group ---

resource "aws_security_group" "prod" {
  name        = "${var.project_name}-sg"
  description = "Allow ssh and app traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# --- EC2 instances ---

resource "aws_instance" "prod" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.prod.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash 
    hostnamectl set-hostname prod-cloud0${count.index + 1}
    curl -fsSL https://tailscale.com/install.sh | sh  
    tailscale up --authkey=${var.tailscale_authkey} --advertise-tags=tag:prod
    EOF

  tags = {
    Name    = "${var.project_name}-prod-cloud0${count.index + 1}"
    Project = var.project_name
    Role    = "prod"
  }
}


