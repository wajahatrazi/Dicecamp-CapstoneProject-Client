output "client_public_ip" {
  value = aws_instance.client_instance.public_ip
}
