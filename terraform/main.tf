provider "aws" {
    region = "us-east-1"
}

data "aws_ssm_parameter" "db_pass" {
    name = "db_pass"
    depends_on = [module.rds]
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.2"

    name = "my-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["us-east-1a", "us-east-1b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

    enable_nat_gateway = false
    enable_vpn_gateway = false

    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Terraform = "true"
        Environment = var.environment
    }
}

module "rds" {
    source = "./modules/RDS"

    subnet_ids = module.vpc.public_subnets
    vpc_id = module.vpc.vpc_id
    vpc_cidr_block = module.vpc.vpc_cidr_block
    environment = var.environment
}

module "ecr" {
    source = "terraform-aws-modules/ecr/aws"
    version = "1.6.0"

    repository_name = "demo-2-syt"
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

module "ecs" {
    source = "./modules/ECS"

    db_host = module.rds.rds_hostname
    db_name = module.rds.rds_db_name
    db_port = module.rds.rds_port
    db_user = module.rds.rds_username
    db_password = aws_ssm_parameter.db_pass.value
    security_group_alb_id = module.alb.security_group_alb_id
    vpc_id = module.vpc.vpc_id
    environment = var.environment
}

module "alb" {
    source = "./modules/ALB"

    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.public_subnets
}