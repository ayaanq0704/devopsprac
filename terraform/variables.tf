variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type - t2.micro is free tier eligible"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of your EC2 key pair"
  type        = string
  default     = "devops-key"
}

variable "app_port" {
  description = "Port the Flask app runs on"
  type        = number
  default     = 5000
}
