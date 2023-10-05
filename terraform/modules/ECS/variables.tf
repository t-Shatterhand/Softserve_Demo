variable "environment" {
    type = string
    default = "dev"
}

variable "region" {
    type = string
    default = "us-east-1"
}

variable "service_name" {
    type = string
    default = "syt"
}

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t3.micro"
  type        = string
}

variable "public_ec2_key" {
    type = string
    default = "deployment-server"
}

variable "ecs_task_desired_count" {
  description = "How many ECS tasks should minimally run in parallel"
  default     = 2
  type        = number
}

variable "ecs_task_deployment_minimum_healthy_percent" {
  description = "How many percent of a service must be running to still execute a safe deployment"
  default     = 50
  type        = number
}

variable "ecs_task_deployment_maximum_percent" {
  description = "How many additional tasks are allowed to run (in percent) while a deployment is executed"
  default     = 100
  type        = number
}

variable "container_port" {
  description = "Port of the container"
  type        = number
  default     = 8080
}

variable "cpu_units" {
  description = "Amount of CPU units for a single ECS task"
  default     = 100
  type        = number
}

variable "memory" {
  description = "Amount of memory in MB for a single ECS task"
  default     = 256
  type        = number
}

variable "retention_in_days" {
  description = "Retention period for Cloudwatch logs"
  default     = 7
  type        = number
}

variable "db_host" {
    type = string
}

variable "db_name" {
    type = string
}

variable "db_port" {
    type = string
}

variable "db_user" {
    type = string
}

variable "db_password" {
    type = string
}

variable "security_group_alb_id" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "ecr_repository_url" {
    type = string
}

variable "target_group_arn" {
    type = string
}