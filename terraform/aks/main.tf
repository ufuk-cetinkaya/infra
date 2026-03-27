terraform {

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateaksdemo1"
    container_name       = "tfstate"
    key                  = "aks.tfstate"
  }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "demo-aks-rg"
  location = "westeurope"
}

resource "azurerm_resource_group" "rg1" {
  name     = "demo-sql-rg"
  location = "austriaeast"
}

resource "azurerm_kubernetes_cluster" "aks" {

  name                      = "demo-aks"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  dns_prefix                = "demoaks"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled  = false
    secret_rotation_interval = "2m"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "standard_b2s_v2"

    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

}

data "azurerm_key_vault" "kv" {
  name                = "demo-aks-vault"
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_mssql_server" "sql" {
  name                         = "edonusum"
  resource_group_name          = azurerm_resource_group.rg1.name
  location                     = "austriaeast"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = data.azurerm_key_vault_secret.sql_password.value

}

resource "azurerm_mssql_database" "appdb" {
  name                 = "gibuserdb"
  server_id            = azurerm_mssql_server.sql.id
  sku_name             = "Basic"
  storage_account_type = "Local"
}

resource "azurerm_mssql_database" "appdb2" {
  name                 = "ebelgedb"
  server_id            = azurerm_mssql_server.sql.id
  sku_name             = "Basic"
  storage_account_type = "Local"
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "allow-azure"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_key_vault" "keyvault" {
  name                = "demo-aks-vault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = "226eefbc-6526-4679-82cb-27d07f52200c"
  sku_name            = "standard"
}
