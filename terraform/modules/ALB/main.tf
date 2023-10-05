resource "aws_alb" "alb" {
  name            = "demo-2-ALB-${var.environment}"
  security_groups = [aws_security_group.alb.id]
  subnets         = var.subnets
}

resource "aws_security_group" "alb" {
    name        = "demo-2_ALB_SecurityGroup_${var.environment}"
    description = "Security group for ALB"
    vpc_id      = var.vpc_id

    egress {
        description = "Allow all egress traffic"
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name     = "demo-2_ALB_SecurityGroup_${var.environment}"
    }
}


resource "aws_lb_listener" "alb_default_listener_http" {
    load_balancer_arn = aws_alb.alb.arn
    port              = "8080"
    protocol          = "HTTP"
    default_action {
        target_group_arn = aws_alb_target_group.service_target_group.id
        type             = "forward"
    }
}

resource "aws_alb_target_group" "service_target_group" {
    name                 = "demo-2-TargetGroup-${var.environment}"
    port                 = "8080"
    protocol             = "HTTP"
    vpc_id               = var.vpc_id
    deregistration_delay = 120

    health_check {
        healthy_threshold   = "2"
        unhealthy_threshold = "2"
        interval            = "60"
        matcher             = var.healthcheck_matcher
        path                = var.healthcheck_endpoint
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "30"
    }
    
    depends_on = [aws_alb.alb]
}