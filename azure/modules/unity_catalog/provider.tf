# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
    azuread = {
      source  = "hashicorp/azuread"
    }
    azapi = {
      source = "azure/azapi"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}





provider "azapi" {
  subscription_id = local.subscription_id
}

provider "azurerm" {
  subscription_id = local.subscription_id
  features {}
}

provider "databricks" {
  azure_workspace_resource_id = data.azurerm_databricks_workspace.this.id
  host                        = local.databricks_workspace_host
}