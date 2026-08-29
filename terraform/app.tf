resource "kubernetes_config_map" "app" {
  metadata {
    name      = "task-manager-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    NODE_ENV      = "production"
    APP_NAME      = "Task Manager"
    DATABASE_HOST = kubernetes_service.postgres.metadata[0].name
    DATABASE_PORT = "5432"
    DATABASE_NAME = var.postgres_db
    DATABASE_USER = var.postgres_user
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "task-manager"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "task-manager"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "task-manager"
      }
    }

    template {
      metadata {
        labels = {
          app = "task-manager"
        }
      }

      spec {
        container {
          name  = "task-manager"
          image = var.app_image_name

          # A imagem é construída e importada localmente para o k3d
          # (ver image_build.tf); "Never" evita que o kubelet tente
          # puxá-la de um registry remoto.
          image_pull_policy = "Never"

          port {
            container_port = 3000
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app.metadata[0].name
            }
          }

          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 15
            period_seconds        = 15
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [
    null_resource.app_image,
    kubernetes_deployment.postgres,
  ]
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "task-manager-service"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = "task-manager"
    }

    port {
      port        = 3000
      target_port = 3000
      node_port   = var.app_node_port
    }
  }
}
