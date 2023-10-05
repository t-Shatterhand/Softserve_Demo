## Get most recent AMI for an ECS-optimized Amazon Linux 2 instance

data "aws_ami" "amazon_linux_2" {
    most_recent = true

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "owner-alias"
        values = ["amazon"]
    }

    filter {
        name   = "name"
        values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
    }

    owners = ["amazon"]
}

resource "aws_launch_template" "ecs_launch_template" {
    name                   = "demo-2_EC2_LaunchTemplate_${var.environment}"
    image_id               = data.aws_ami.amazon_linux_2.id
    instance_type          = var.instance_type
    key_name               = var.public_ec2_key
    user_data              = base64encode(data.template_file.user_data.rendered)
    vpc_security_group_ids = [aws_security_group.ec2.id]

    iam_instance_profile {
        arn = aws_iam_instance_profile.ec2_instance_role_profile.arn
    }

    monitoring {
        enabled = true
    }
}

data "template_file" "user_data" {
    template = "${file("${path.module}/user_data.sh")}"
    vars = {
        ecs_cluster_name = aws_ecs_cluster.cluster.name
    }
}

resource "aws_iam_role" "ec2_instance_role" {
    name               = "demo-2_EC2_InstanceRole_${var.environment}"
    assume_role_policy = data.aws_iam_policy_document.ec2_instance_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
    role       = aws_iam_role.ec2_instance_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
    name  = "demo-2_EC2_InstanceRoleProfile_${var.environment}"
    role  = aws_iam_role.ec2_instance_role.id
}

data "aws_iam_policy_document" "ec2_instance_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        effect  = "Allow"

        principals {
        type        = "Service"
        identifiers = [
            "ec2.amazonaws.com",
            "ecs.amazonaws.com"
        ]
        }
    }
}

resource "aws_ecs_cluster" "cluster" {
    name  = "demo-2_ECSCluster_${var.environment}"

    lifecycle {
        create_before_destroy = true
    }

    tags = {
        Name     = "demo-2_ECSCluster_${var.environment}"
    }
}

resource "aws_ecs_service" "service" {
    name                               = "demo-2_ECS_Service_${var.environment}"
    iam_role                           = aws_iam_role.ecs_service_role.arn
    cluster                            = aws_ecs_cluster.cluster.id
    task_definition                    = aws_ecs_task_definition.default.arn
    launch_type                        = "EC2"
    desired_count                      = var.ecs_task_desired_count
    deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
    deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent

    load_balancer {
        target_group_arn = var.target_group_arn
        container_name   = var.service_name
        container_port   = var.container_port
    }

    ## Spread tasks evenly accross all Availability Zones for High Availability
    ordered_placement_strategy {
        type  = "spread"
        field = "attribute:ecs.availability-zone"
    }
    
    ## Make use of all available space on the Container Instances
    ordered_placement_strategy {
        type  = "binpack"
        field = "memory"
    }

    ## Do not update desired count again to avoid a reset to this number on every deployment
    lifecycle {
        ignore_changes = [desired_count]
    }
}

resource "aws_iam_role" "ecs_service_role" {
    name               = "demo-2_ECS_ServiceRole_${var.environment}"
    assume_role_policy = data.aws_iam_policy_document.ecs_service_policy.json
}

data "aws_iam_policy_document" "ecs_service_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        effect  = "Allow"

        principals {
        type        = "Service"
        identifiers = ["ecs.amazonaws.com",]
        }
    }
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name   = "demo-2_ECS_ServiceRolePolicy_${var.environment}"
    policy = data.aws_iam_policy_document.ecs_service_role_policy.json
    role   = aws_iam_role.ecs_service_role.id
}

data "aws_iam_policy_document" "ecs_service_role_policy" {
    statement {
        effect  = "Allow"
        actions = [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "ec2:DescribeTags",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:PutSubscriptionFilter",
        "logs:PutLogEvents",
        "ecr:*",
        "ssm:*"
        ]
        resources = ["*"]
    }
}

resource "aws_ecs_task_definition" "default" {
    family             = "demo-2_ECS_TaskDefinition_${var.environment}"
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn      = aws_iam_role.ecs_task_iam_role.arn

    container_definitions = jsonencode([
        {
        name         = var.service_name
        image        = "${var.ecr_repository_url}:latest"
        cpu          = var.cpu_units
        memory       = var.memory
        essential    = true
        portMappings = [
            {
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
            }
        ]
        logConfiguration = {
            logDriver = "awslogs",
            options   = {
            "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
            "awslogs-region"        = var.region,
            "awslogs-stream-prefix" = "app"
            }
        }
        "environment": [
        {
          "name": "ENV_DB_ENGINE",
          "value": "django.db.backends.postgresql"
        },
        {
          "name": "ENV_DB_HOST",
          "value": var.db_host
        },
        {
          "name": "ENV_DB_NAME",
          "value": var.db_name
        },
        {
          "name": "ENV_DB_PORT",
          "value": var.db_port
        },
        {
          "name": "ENV_DB_USER",
          "value": var.db_user
        },
        {
          "name": "ENV_DB_PASSWORD",
          "value": var.db_password
        } ]
        }
    ])
}

resource "aws_cloudwatch_log_group" "log_group" {
    name              = "/demo/ecs/${var.service_name}"
    retention_in_days = var.retention_in_days
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name               = "demo-2_ECS_TaskExecutionRole_${var.environment}"
    assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

data "aws_iam_policy_document" "task_assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_iam_role" {
    name               = "demo-2_ECS_TaskIAMRole_${var.environment}"
    assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

## SG for EC2 instances

resource "aws_security_group" "ec2" {
    name        = "demo-2_EC2_Instance_SecurityGroup_${var.environment}"
    description = "Security group for EC2 instances in ECS cluster"
    vpc_id      = var.vpc_id

    ingress {
        description     = "Allow ingress traffic from ALB on HTTP on ephemeral ports"
        from_port       = 1024
        to_port         = 65535
        protocol        = "tcp"
        security_groups = [var.security_group_alb_id]
    }

    egress {
        description = "Allow all egress traffic"
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name     = "demo-2_EC2_Instance_SecurityGroup_${var.environment}"
    }
}

## Creates Capacity Provider linked with ASG and ECS Cluster

resource "aws_ecs_capacity_provider" "cas" {
    name  = "demo-2_ECS_CapacityProvider_${var.environment}"

    auto_scaling_group_provider {
        auto_scaling_group_arn         = aws_autoscaling_group.ecs_autoscaling_group.arn
        managed_termination_protection = "ENABLED"

        managed_scaling {
        maximum_scaling_step_size = var.maximum_scaling_step_size
        minimum_scaling_step_size = var.minimum_scaling_step_size
        status                    = "ENABLED"
        target_capacity           = var.target_capacity
        }
    }
}

resource "aws_ecs_cluster_capacity_providers" "cas" {
    cluster_name       = aws_ecs_cluster.cluster.name
    capacity_providers = [aws_ecs_capacity_provider.cas.name]
}

## Define Target Tracking on ECS Cluster Task level

resource "aws_appautoscaling_target" "ecs_target" {
    max_capacity       = var.ecs_task_max_count
    min_capacity       = var.ecs_task_min_count
    resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
}

## Policy for CPU tracking
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
    name               = "demo-2_CPUTargetTrackingScaling_${var.environment}"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

    target_tracking_scaling_policy_configuration {
        target_value = var.cpu_target_tracking_desired_value

        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
    }
}

## Policy for memory tracking
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
    name               = "demo-2_MemoryTargetTrackingScaling_${var.environment}"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

    target_tracking_scaling_policy_configuration {
        target_value = var.memory_target_tracking_desired_value

        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
    }
}

## Creates an ASG linked with our main VPC

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
    name                  = "demo-2_ASG_${var.environment}"
    max_size              = var.autoscaling_max_size
    min_size              = var.autoscaling_min_size
    vpc_zone_identifier   = var.private_subnets_ids
    health_check_type     = "EC2"
    protect_from_scale_in = true

    enabled_metrics = [
        "GroupMinSize",
        "GroupMaxSize",
        "GroupDesiredCapacity",
        "GroupInServiceInstances",
        "GroupPendingInstances",
        "GroupStandbyInstances",
        "GroupTerminatingInstances",
        "GroupTotalInstances"
    ]

    launch_template {
        id      = aws_launch_template.ecs_launch_template.id
        version = "$Latest"
    }

    instance_refresh {
        strategy = "Rolling"
    }

    lifecycle {
        create_before_destroy = true
    }

    tag {
        key                 = "Name"
        value               = "demo-2_ASG_${var.environment}"
        propagate_at_launch = true
    }
}
