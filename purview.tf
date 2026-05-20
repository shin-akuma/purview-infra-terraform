# ============================================================
# purview.tf
# Microsoft Purview Account
# System-assigned MI, no public access, managed resource group
# ============================================================

resource "azurerm_purview_account" "purview" {
  name                = var.purview_account_name
  resource_group_name = azurerm_resource_group.purview.name
  location            = azurerm_resource_group.purview.location
  tags                = var.tags

  # System-assigned managed identity — used for RBAC on data sources
  identity {
    type = "SystemAssigned"
  }

  # Azure-managed resource group for Purview's internal Storage + Event Hub
  managed_resource_group_name = "${var.purview_account_name}-managed-rg"
  # Note: public_network_access is controlled post-deployment via Purview network settings
}
