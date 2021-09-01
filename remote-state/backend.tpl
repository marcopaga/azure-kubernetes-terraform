terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "terraform"
    container_name       = "terraform-state-container"
  }
}
