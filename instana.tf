resource "kubernetes_namespace" "instana-agent" {
  metadata {
    name = "instana-agent"
  }
}

resource "helm_release" "instana-agent" {
  chart         = "stable/instana-agent"
  name          = "instana-agent"
  version       = "1.0.13"
  namespace     = "instana-agent"
  recreate_pods = true
  depends_on = [
    kubernetes_namespace.instana-agent,
    kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb
  ]
  timeout = "600"

  values = [
    templatefile("instana-values.tpl", {
      cluster_name = azurerm_kubernetes_cluster.k8s.name,
      agent_key    = var.instana_agent_key
    })
  ]

  set {
    name = "agent.configuration_yaml"
    value = templatefile("instana-agent-values.yaml", {
      zone_name = azurerm_kubernetes_cluster.k8s.name
    })
  }
}