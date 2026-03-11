terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Fetch latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================================
# SECURITY GROUP
# ============================================================
resource "aws_security_group" "web_sg" {
  name        = "url-shortener-sg"
  description = "Security group for URL shortener web app"

  # SSH restricted to specific IP
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/32"]
  }

  # HTTP access
  ingress {
    description = "HTTP web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask port
  ingress {
    description = "Flask application port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "url-shortener-sg"
    Environment = "demo"
    Project     = "devops-assignment"
  }
}

# ============================================================
# EC2 INSTANCE
# ============================================================

resource "aws_instance" "web_server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Enable IMDSv2 for security
  metadata_options {
    http_tokens = "required"
  }

  # Encrypted root disk
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    encrypted   = true
  }

  # Startup script
  user_data = <<-EOF
#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io docker-compose git

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu

cd /home/ubuntu

git clone https://github.com/ayaanq0704/devopsprac.git app

cd app

docker-compose up -d
EOF

  tags = {
    Name        = "url-shortener-server"
    Environment = "demo"
    Project     = "devops-assignment"
  }
}