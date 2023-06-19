provider "azuread" {
  version = "~>0.6.0"
}

provider "azurerm" {
  version = "~>1.5"
}

provider "kubernetes" {
  version                = "~> 2.0"
  host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)

  load_config_file = false
  config_path      = "~/.kube/we-really-dont-want-terraform-to-read-the-local-config"
}

provider "helm" {
  debug           = true
  version         = "~> 0.10"
  install_tiller  = true
  service_account = "tiller"

  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)

    load_config_file = false
    config_path      = "~/.kube/we-really-dont-want-terraform-to-read-the-local-config"
  }

}

provider "random" {
  version = "~> 2.2.0"
}