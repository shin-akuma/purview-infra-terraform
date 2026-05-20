# ============================================================
# key_vault.tf
# Key Vault — RBAC model, private-only, purge protection enabled
# ============================================================

resource "azurerm_key_vault" "purview" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.purview.location
  resource_group_name = azurerm_resource_group.purview.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.tags

  # RBAC model — no legacy access policies
  rbac_authorization_enabled = true

  # Hardened retention settings
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = true

  # Private endpoint only — no public access
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = []
  }
}
