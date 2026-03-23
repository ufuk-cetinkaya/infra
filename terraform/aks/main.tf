provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "demo-aks-rg"
  location = "westeurope"
}

resource "azurerm_kubernetes_cluster" "aks" {

  name                = "demo-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "demoaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "standard_b2s_v2"
  }

  identity {
    type = "SystemAssigned"
  }

}