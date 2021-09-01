data "azurerm_subscription" "sub" {

}

resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.location
}

resource "azuread_application" "cluster-app" {
  name = var.cluster_name
}

resource "azuread_service_principal" "cluster-sp" {
  application_id = azuread_application.cluster-app.application_id
}

resource "random_string" "aks_sp_password" {
  length  = 32
  special = false

  keepers = {
    service_principal = azuread_service_principal.cluster-sp.id
  }
}

resource "azuread_service_principal_password" "aks_sp_password" {
  service_principal_id = azuread_service_principal.cluster-sp.id
  value                = random_string.aks_sp_password.result
  end_date             = timeadd(timestamp(), "8760h")

  # This stops be 'end_date' changing on each run and causing a new password to be set
  # to get the date to change here you would have to manually taint this resource...
  lifecycle {
    ignore_changes = ["end_date"]
  }
}

resource "azurerm_role_assignment" "assignment" {
  scope                = data.azurerm_subscription.sub.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.cluster-sp.id
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = "1.14.8"

  role_based_access_control {
    enabled = true
  }

  agent_pool_profile {
    type                = "AvailabilitySet"
    name                = "default"
    count               = var.agent_count
    vm_size             = "Standard_D8s_v3"
    os_type             = "Linux"
    os_disk_size_gb     = 62
    enable_auto_scaling = false
  }

  lifecycle {
    ignore_changes = [
      "agent_pool_profile[0].count"
    ]
  }

  service_principal {
    client_id     = azuread_service_principal.cluster-sp.application_id
    client_secret = random_string.aks_sp_password.result
  }

  tags = {
    Environment = "Development"
  }
}
