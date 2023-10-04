provider "aws" {
    region = "eu-north-1"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.2"

    name = "my-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["eu-north-1a", "eu-north-1b"]
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

module "public_ecr" {
    source = "terraform-aws-modules/ecr/aws"
    version = "1.6.0"

    repository_name = "demo-2-syt"
    repository_type = "public"

    repository_read_write_access_arns = [var.iam_arn]
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
        about_text        = file("${path.module}/files/ABOUT.md")
        usage_text        = file("${path.module}/files/USAGE.md")
        operating_systems = ["Linux"]
        architectures     = ["x86"]
        logo_image_blob   = filebase64("${path.module}/files/clowd.png")
    }

    tags = {
        Terraform   = "true"
        Environment = "dev"
    }
}