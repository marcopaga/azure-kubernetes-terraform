data "azurerm_subscription" "sub" {
}

resource "azurerm_resource_group" "state" {
  name     = var.state_resource_group_name
  location = var.state_location
}

resource "azurerm_storage_account" "account" {
  name                     = var.state_storage_account_name
  resource_group_name      = azurerm_resource_group.state.name
  location                 = var.state_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.state_container_name
  storage_account_name  = azurerm_storage_account.account.name
  container_access_type = "private"
}