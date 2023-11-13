provider "aws" {
    region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "db_pass" {
  name = "db_pass"
  depends_on = [
        module.rds
  ]
}

data "aws_secretsmanager_secret_version" "db_pass_latest" {
  secret_id = data.aws_secretsmanager_secret.db_pass.id
  depends_on = [
        module.rds
  ]
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_lb" "ingress_alb" {
  tags = var.alb_tag

  depends_on = [
    kubernetes_ingress_v1.shareyourtext_ingress
  ]
}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.2"

    name = "my-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["us-east-1a", "us-east-1b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

    enable_nat_gateway = true
    enable_vpn_gateway = false

    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "demo-3-vpc-23.10"
        Terraform = "true"
        Environment = var.environment
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${var.eks_name}": "owned"
    }
    public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.eks_name}": "owned"
    }
}

module "rds" {
    source = "./modules/RDS"

    subnet_ids = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id
    vpc_cidr_block = module.vpc.vpc_cidr_block
    environment = var.environment
}

module "ecr" {
    source = "terraform-aws-modules/ecr/aws"
    version = "1.6.0"

    repository_name = "demo-3-syt"
    repository_type = "public"

    repository_read_write_access_arns = []
    repository_lifecycle_policy = jsonencode({
        rules = [
        {
            rulePriority = 1,
            description  = "Keep last 10 images",
            selection = {
                tagStatus     = "tagged",
                tagPrefixList = ["v"],
                countType     = "imageCountMoreThan",
                countNumber   = 10
            },
            action = {
                type = "expire"
            }
        }
        ]
    })

    public_repository_catalog_data = {
        description       = "Docker container for some things"
        about_text        = "About text here"
        usage_text        = "Usage text here"
        operating_systems = ["Linux"]
        architectures     = ["x86"]
    }

    tags = {
        Terraform   = "true"
        Environment = "demo"
    }
}

module "dns" {
    source = "./modules/DNS"

    domain = var.domain
}

resource "aws_route53_record" "lb_record" {
  name    = "app.${var.domain}"
  zone_id = module.dns.zone_id
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress_alb.dns_name
    zone_id                = data.aws_lb.ingress_alb.zone_id
    evaluate_target_health = true
  }
}

/* OLD --------
Deployment via ECS, ALB created separately
Moved on to EKS instead

module "ecs" {
    source = "./modules/ECS"

    db_host = module.rds.rds_hostname
    db_name = module.rds.rds_db_name
    db_port = module.rds.rds_port
    db_user = module.rds.rds_username
    db_password = data.aws_ssm_parameter.db_pass.value
    security_group_alb_id = module.alb.security_group_alb_id
    vpc_id = module.vpc.vpc_id
    ecr_repository_url = module.ecr.repository_url
    target_group_arn = module.alb.target_group_arn
    private_subnets_ids = module.vpc.private_subnets
    environment = var.environment
}

module "alb" {
    source = "./modules/ALB"
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.public_subnets
}

*/