terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }

  # --------------------------------------------------------
  # Uncomment and fill in before running terraform init.
  # The storage account must be pre-created out-of-band.
  # --------------------------------------------------------
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstatebsup"
  #   container_name       = "tfstate"
  #   key                  = "jason-super/purview.tfstate"
  # }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    key_vault {
      # Never purge on destroy — protect production secrets
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azurerm" {
  alias           = "hub"
  subscription_id = coalesce(var.existing_private_dns_zone_subscription_id, var.subscription_id)

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azapi" {}
