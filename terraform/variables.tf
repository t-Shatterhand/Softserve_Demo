variable "region" {
  #default region to deploy infrastructure
  type    = string
  default = "us-east-1"
}

variable "environment" {
  #default environment to tag infrastructure
  type    = string
  default = "demo-3"
}

variable "eks_name" {
  #name for eks cluster
  type    = string
  default = "demo-3-EKS"
}

variable "tags" {
  #tags for eks cluster
  type    = map(string)
  default = {"env" = "demo-3"}
}

variable "env_name" {
  #environment name for eks cluster
  type    = string
  default = "demo-3"
}

variable "alb_tag" {
  #alb tag for data to retrieve
  type = map(string)
  default = {
    MyController = "true"
  }
}

variable "domain" {
  #domain of the hosted zone
  description = "Domain name for hosted zone"
  default = "kostroba.pp.ua"
  type = string
}