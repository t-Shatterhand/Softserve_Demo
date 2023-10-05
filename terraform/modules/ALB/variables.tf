variable "environment" {
    type = string
    default = "dev"
}

variable "subnets" {
    type = list(string)
}

variable "vpc_id" {
    type = string
}

variable "healthcheck_endpoint" {
  description = "Endpoint for ALB healthcheck"
  type        = string
  default     = "/"
}

variable "healthcheck_matcher" {
  description = "HTTP status code matcher for healthcheck"
  type        = string
  default     = "200"
}
