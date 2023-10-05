output "security_group_alb_id" {
  value = aws_security_group.alb.id
}

output "target_group_arn" {
  value = aws_alb_target_group.service_target_group.arn
}