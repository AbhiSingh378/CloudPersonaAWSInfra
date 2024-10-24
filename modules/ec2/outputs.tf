output "app_security_group_id" {
  value = aws_security_group.app_sg.id
}

output "instance_id" {
  value = aws_instance.app_server.id
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}