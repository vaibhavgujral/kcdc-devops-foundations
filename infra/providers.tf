terraform {
  required_version = ">= 1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER"   # passed via -backend-config in the pipeline
    storage_account_name = "PLACEHOLDER"
    container_name       = "tfstate"
    key                  = "quoteboard.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}