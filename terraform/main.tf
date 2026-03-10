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

# Dynamically fetch the latest Ubuntu 22.04 AMI
# Why? Hardcoding AMI IDs breaks across regions and goes stale
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account

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
# SECURITY GROUP - Controls what traffic reaches our server
# ============================================================
resource "aws_security_group" "web_sg" {
  name        = "url-shortener-sg"
  description = "Security group for URL shortener web app"

  # ⚠️ INTENTIONAL VULNERABILITY #1:
  # SSH open to entire internet (0.0.0.0/0)
  # Risk: Anyone in the world can attempt to brute-force SSH login
  # This WILL be flagged by Trivy as CRITICAL
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠️ VULNERABLE - open to all
  }

  # HTTP access - needed for the app (acceptable to be public)
  ingress {
    description = "HTTP web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask app port
  ingress {
    description = "Flask application port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "url-shortener-sg"
    Environment = "demo"
    Project     = "devops-assignment"
  }
}

# ============================================================
# EC2 INSTANCE - The virtual machine running our app
# ============================================================
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # ⚠️ INTENTIONAL VULNERABILITY #2:
  # Root volume is NOT encrypted
  # Risk: If AWS disk is somehow accessed physically or via snapshot,
  # data is exposed in plaintext
  # This WILL be flagged by Trivy as HIGH
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    encrypted   = false  # ⚠️ VULNERABLE - should be true
  }

  # Startup script: installs Docker and runs our app automatically
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
