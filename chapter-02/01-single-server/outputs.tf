output "public_ip" {
  description = "The public IPv4 address of the web server"
  value       = aws_instance.example.public_ip
}

output "web_url" {
  description = "The URL of the web server"
  value       = "http://${aws_instance.example.public_ip}:${var.server_port}"
}
