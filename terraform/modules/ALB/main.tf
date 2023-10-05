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

resource "aws_security_group_rule" "alb_8080_only" {
    security_group_id = aws_security_group.alb.id
    from_port         = 8080
    protocol          = "tcp"
    to_port           = 8080
    type              = "ingress"
}
