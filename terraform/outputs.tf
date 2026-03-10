# Output the public IP so we can access the app after deployment
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "app_url" {
  description = "URL to access the URL shortener app"
  value       = "http://${aws_instance.web_server.public_ip}:5000"
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web_server.id
}
