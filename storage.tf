# ============================================================
# storage.tf
# Storage Account for Purview diagnostic log archival
# GRS, TLS 1.2+, no public access, soft-delete enabled
# ============================================================

resource "azurerm_storage_account" "diagnostic" {
  name                = var.diagnostic_storage_account_name
  resource_group_name = azurerm_resource_group.purview.name
  location            = azurerm_resource_group.purview.location
  tags                = var.tags

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  # Security hardening
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = []
  }

  blob_properties {
    delete_retention_policy {
      days = 90
    }
    container_delete_retention_policy {
      days = 90
    }
  }
}
