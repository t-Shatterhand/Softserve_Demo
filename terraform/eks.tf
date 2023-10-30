module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "19.5.1"

    cluster_addons = {
        coredns = {
            preserve    = true
            most_recent = true

            timeouts = {
                create = "25m"
                delete = "10m"
            }
        }
        kube-proxy = {
            most_recent = true
        }
        vpc-cni = {
            most_recent = true
        }
    }

    cluster_name                    = var.eks_name
    cluster_version                 = "1.28"
    cluster_endpoint_private_access = true
    cluster_endpoint_public_access  = true

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
    control_plane_subnet_ids = module.vpc.public_subnets

    enable_irsa = true

    eks_managed_node_group_defaults = {
        ami_type               = "AL2_x86_64"
        cluster_additional_security_group_ids = [aws_security_group.eks_cluster.id]
        disk_size              = 20
        instance_types         = ["t3.small"]
        vpc_security_group_ids = [aws_security_group.eks_node.id]
    }

    eks_managed_node_groups = {
        green = {
            min_size     = 2
            max_size     = 2
            desired_size = 2

            instance_types = ["t3.small"]
            capacity_type  = "SPOT"
            labels = var.tags 
            taints = {
            }
            tags = var.tags
        }
    }

    node_security_group_tags = {
        "kubernetes.io/cluster/${var.eks_name}" = null
    }

    tags = var.tags
}

resource "aws_security_group" "eks_node" {
    name        = "${var.env_name} eks node"
    description = "Allow traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description      = "World"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge({
        Name = "EKS ${var.env_name}",
        "kubernetes.io/cluster/${var.eks_name}": "owned"
    }, var.tags)
}

resource "aws_security_group" "eks_cluster" {
    name        = "${var.env_name} eks cluster"
    description = "Allow traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description      = "Only me"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["${chomp(data.http.myip.response_body)}/32"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge({
        Name = "EKS ${var.env_name}",
        "kubernetes.io/cluster/${var.eks_name}": "owned"
    }, var.tags)
}