resource "kubernetes_namespace" "app" {
  metadata {
    name = "tfk8s"
  }
}

resource "kubernetes_config_map_v1" "app_cfg" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  data = {
    WELCOME_MESSAGE = "Hello from Terraform 👋"
  }
}

resource "kubernetes_deployment_v1" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "web"
    }
  }

  spec {
    replicas    =    1

    selector {
      match_labels = {
        app = "web"
      }
    }

    template {
      metadata {
        labels = {
          app = "web"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:stable"
          port {
            container_port = 80
          }
          # (optional) show wiring to ConfigMap as env
          env {
            name = "WELCOME_MESSAGE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map_v1.app_cfg.metadata[0].name
                key  = "WELCOME_MESSAGE"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "web_svc" {
  metadata {
    name      = "web-service"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "web"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

