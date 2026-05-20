# ============================================================
# rbac.tf
# RBAC assignments for the Purview Managed Identity
# Terraform handles cross-RG and cross-sub scopes natively —
# no module gymnastics required
# ============================================================

# ---- Subscription-level Reader --------------------------------
# Allows Purview to enumerate all resources in the subscription

resource "azurerm_role_assignment" "purview_subscription_reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azurerm_purview_account.purview.identity[0].principal_id
  description          = "Purview MI — subscription-level Reader for resource enumeration"
}

# ---- Key Vault Secrets User -----------------------------------
# Allows Purview to retrieve scan credentials stored in KV

resource "azurerm_role_assignment" "purview_kv_secrets_user" {
  scope                = azurerm_key_vault.purview.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_purview_account.purview.identity[0].principal_id
  description          = "Purview MI — Key Vault Secrets User for scan credential retrieval"
}

# ---- Diagnostic Storage Blob Data Contributor ----------------
# Allows Purview to write scan insights to the diagnostic storage account

resource "azurerm_role_assignment" "purview_diagnostic_storage_contributor" {
  scope                = azurerm_storage_account.diagnostic.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_purview_account.purview.identity[0].principal_id
  description          = "Purview MI — Storage Blob Data Contributor on diagnostic storage"
}

# ---- ADLS Gen2 Storage Blob Data Reader ----------------------
# Allows Purview to read data for classification and schema extraction

resource "azurerm_role_assignment" "purview_adls_reader" {
  scope                = var.adls_storage_account_resource_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_purview_account.purview.identity[0].principal_id
  description          = "Purview MI — Storage Blob Data Reader on ADLS Gen2 for scanning"
}

# ---- Azure Databricks Reader ---------------------------------
# Allows Purview to enumerate Databricks workspace metadata via Unity Catalog connector
# Additional permissions inside Databricks/Unity Catalog are granted out-of-band

resource "azurerm_role_assignment" "purview_databricks_reader" {
  scope                = var.databricks_workspace_resource_id
  role_definition_name = "Reader"
  principal_id         = azurerm_purview_account.purview.identity[0].principal_id
  description          = "Purview MI — Reader on Databricks workspace for Unity Catalog connector"
}
