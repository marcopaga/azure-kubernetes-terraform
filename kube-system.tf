resource "helm_release" "node-problem-detector" {
  chart      = "stable/node-problem-detector"
  name       = "node-problem-detector"
  version    = "1.5.2"
  namespace  = "kube-system"
  depends_on = [kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb]
  timeout    = "600"
}

resource "helm_release" "kured" {
  chart      = "stable/kured"
  name       = "reboot-daemon"
  version    = "1.3.1"
  namespace  = "kube-system"
  depends_on = [kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb]
  timeout    = "600"
}

resource "helm_release" "traefik" {
  chart      = "stable/traefik"
  name       = "traefik"
  version    = "1.77.0"
  namespace  = "kube-system"
  values     = [file("traefik-values.yaml")]
  depends_on = [kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb]
  timeout    = "600"

  set {
    name  = "acme.staging"
    value = var.acme_staging
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_CLIENT_ID"
    value = azuread_service_principal.cluster-sp.application_id
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_CLIENT_SECRET"
    value = random_string.aks_sp_password.result
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_SUBSCRIPTION_ID"
    value = data.azurerm_subscription.sub.subscription_id
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_TENANT_ID"
    value = data.azurerm_subscription.sub.tenant_id
  }

  set {
    name  = "acme.dnsProvider.azure.AZURE_RESOURCE_GROUP"
    value = "dns-resource-group"
  }

  set {
    name  = "kubernetes.ingressEndpoint.publishedService"
    value = "kube-system/traefik"
  }
}

resource "helm_release" "cluster-autoscaler" {
  chart     = "stable/cluster-autoscaler"
  name      = "cluster-autoscaler"
  version   = "5.0.0"
  namespace = "kube-system"
  values = [
    templatefile("cluster-autoscaler-values.tpl", {
      cluster_name        = azurerm_kubernetes_cluster.k8s.name,
      sp_client_id        = azuread_service_principal.cluster-sp.application_id,
      sp_client_secret    = random_string.aks_sp_password.result,
      subscription_id     = data.azurerm_subscription.sub.subscription_id,
      tenant_id           = data.azurerm_subscription.sub.tenant_id,
      resource_group      = azurerm_resource_group.k8s.name,
      node_resource_group = azurerm_kubernetes_cluster.k8s.node_resource_group
    })
  ]

  depends_on = [kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb]
}

resource "kubernetes_cluster_role_binding" "view-dashboard" {

  metadata {
    name = "view-dashboard"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }

}