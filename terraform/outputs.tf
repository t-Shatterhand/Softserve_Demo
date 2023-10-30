output "rds_hostname" {
  value = module.rds.rds_hostname
}

output "rds_port" {
  value = module.rds.rds_port
}

output "rds_db_name" {
  value = module.rds.rds_db_name 
}

output "rds_username" {
  value = module.rds.rds_username
}

output "rds_status" {
  value = module.rds.rds_status
}

output "rds_engine" {
  value = module.rds.rds_engine
}

output "ecr_url" {
    value = module.ecr.repository_url
}

output "alb_hostname" {
  value = kubernetes_ingress_v1.example_ingress.status[0].load_balancer[0].ingress[0].hostname
}