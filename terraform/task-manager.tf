resource "kubernetes_config_map" "task_manager_config" {
  depends_on = [null_resource.task_manager_image]

  metadata {
    name = "task-manager-config"
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

resource "kubernetes_deployment" "task_manager" {
  depends_on = [null_resource.task_manager_image, kubernetes_deployment.postgres]

  metadata {
    name = "task-manager"
    labels = {
      app = "task-manager"
    }
  }

  spec {
    replicas = 2

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
          name              = "task-manager"
          image             = var.task_manager_image
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 3000
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.task_manager_config.metadata[0].name
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
            initial_delay_seconds = 10
            period_seconds         = 15
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds         = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "task_manager" {
  metadata {
    name = "task-manager-service"
  }

  spec {
    type = "NodePort"

    selector = {
      app = "task-manager"
    }

    port {
      port        = 3000
      target_port = 3000
      node_port   = var.node_port
    }
  }
}
