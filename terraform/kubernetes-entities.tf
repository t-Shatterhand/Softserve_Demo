resource "kubernetes_deployment" "shareyourtext" {
  metadata {
    name = "shareyourtext"
    labels = {
      App = "shareyourtext"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "shareyourtext"
      }
    }
    template {
      metadata {
        labels = {
          App = "shareyourtext"
        }
      }
      spec {
        container {
          image = "${module.ecr.repository_url}:latest"
          name  = "demo-3-syt"

          env {
            name = "ENV_DB_ENGINE"
            value = "django.db.backends.postgresql"
          }

          env {
            name = "ENV_DB_HOST"
            value = module.rds.rds_hostname
          }

          env {
            name = "ENV_DB_NAME"
            value = module.rds.rds_db_name
          }

          env {
            name = "ENV_DB_PORT"
            value = module.rds.rds_port
          }

          env {
            name = "ENV_DB_USER"
            value = module.rds.rds_username
          }

          env {
            name = "ENV_DB_PASSWORD"
            value = data.aws_ssm_parameter.db_pass.value
          }

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "shareyourtext_ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "shareyourtext-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn": module.dns.certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect" = 443
      "alb.ingress.kubernetes.io/tags": "${keys(var.alb_tag)[0]}=${values(var.alb_tag)[0]}"
      "alb.ingress.kubernetes.io/listen-ports": jsonencode([{"HTTP"=80}, {"HTTPS"=443}])
    }
  }

  spec {
    ingress_class_name = "alb"
    default_backend {
      service {
        name = "shareyourtext"
        port {
          number = 80
        }
      }
    }
    rule {
      host = "app.${var.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.shareyourtext_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
          path = "/*"
        }
      }
    }
  }

  depends_on = [
    helm_release.lb,
    kubernetes_service_account.service-account,
    module.lb_role
  ]
}

resource "kubernetes_service_v1" "shareyourtext_service" {
  metadata {
    name = "shareyourtext"
  }

  spec {
    selector = {
      App = "shareyourtext"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "NodePort"
  }
}