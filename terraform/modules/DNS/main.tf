resource "aws_route53_zone" "kostroba" {
    name = "kostroba.pp.ua"

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_route53_record" "load_balancer" {
    name    = var.domain
    zone_id = aws_route53_zone.kostroba.zone_id
    type    = "A"

    alias {
        name                   = var.alb_domain_name
        zone_id                = var.alb_zone_id
        evaluate_target_health = true
    }
}