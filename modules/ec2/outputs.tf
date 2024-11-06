output "app_security_group_id" {
  value = aws_security_group.app_sg.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.app_lb.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "launch_template_id" {
  value = aws_launch_template.app_template.id
}