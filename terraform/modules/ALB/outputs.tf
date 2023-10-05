output "security_group_alb_id" {
  value = aws_security_group.alb.id
}

output "target_group_arn" {
  value = aws_alb_target_group.service_target_group.arn
}

output "alb_arn" {
  value = aws_alb.alb.arn
}

output "alb_domain_name" {
  value = aws_alb.alb.dns_name
}

output "alb_zone_id" {
  value = aws_alb.alb.zone_id
}