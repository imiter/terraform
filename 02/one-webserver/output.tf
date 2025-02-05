output "public_ip" {
  value = aws_instance.web_server.public_ip
  description = "myEC2 Instance public_ip address"
}

output "public_dns" {
  value = aws_instance.web_server.public_dns
}