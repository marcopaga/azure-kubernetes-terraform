resource "kubernetes_namespace" "app-namespace" {
  metadata {
    name = "app-namespace"
  }
}

resource "kubernetes_resource_quota" "app-namespace-quota" {
  metadata {
    name      = "app-namespace-quota"
    namespace = "app-namespace"
  }
  spec {
    hard = {
      cpu    = 48
      memory = "192Gi"
    }
  }
}