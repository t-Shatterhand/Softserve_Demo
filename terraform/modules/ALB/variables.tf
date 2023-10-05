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
