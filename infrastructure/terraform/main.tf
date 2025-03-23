terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.52.0"
    }
  }

  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "azresources/terraform.state"
    resource_group_name  = "gmc-storage"
    storage_account_name = "gmcstate1"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg" {
  name     = "gmc-ai-rg"
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name 						          = "gmchubstorage"
  location            				  = azurerm_resource_group.rg.location
  resource_group_name 				  = azurerm_resource_group.rg.name
  account_tier 						  = "Standard"
  account_replication_type 			  = "LRS"
}

resource "azurerm_key_vault" "key_vault" {
  name                        = "gmc-key-vault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

#   soft_delete_enabled         = true
  purge_protection_enabled    = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Delete",
      "Purge",
      "Recover",
      "Backup",
      "Restore",
      "Import"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover",
      "Backup",
      "Restore"
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Purge",
      "Recover",
      "Backup",
      "Restore"
    ]
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_container_registry" "acr" {
  name                     = "gmccr"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  sku                      = "Basic"
  admin_enabled            = true

  tags = {
    environment = "production"
  }
}

resource "azurerm_application_insights" "app_insights" {
  name                = "gmc-app-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = {
    environment = "production"
  }
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "gmc-log-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"

  retention_in_days   = 30

  tags = {
    environment = "production"
  }
}

resource "azurerm_cognitive_account" "cognitive_services" {
  name                = "gmc-cognitive-services"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "CognitiveServices"
  sku_name            = "S1" # invalid sku

#   properties = {
#     apiProperties = {
#       qnaRuntimeEndpoint = "https://your-qna-runtime-endpoint"
#     }
#   }

  tags = {
    environment = "production"
  }
}

# resource "azurerm_machine_learning_workspace" "ml_workspace" {
#   name                = "gmc-ml-workspace"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   sku_name            = "Basic"

#   tags = {
#     environment = "production"
#   }
# }
