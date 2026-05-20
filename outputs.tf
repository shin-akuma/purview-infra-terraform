# ============================================================
# outputs.tf
# Key values surfaced after apply
# ============================================================

output "resource_group_name" {
  description = "Name of the deployed Purview resource group"
  value       = azurerm_resource_group.purview.name
}

output "purview_account_name" {
  description = "Name of the Purview account"
  value       = azurerm_purview_account.purview.name
}

output "purview_resource_id" {
  description = "Resource ID of the Purview account"
  value       = azurerm_purview_account.purview.id
}

output "purview_managed_identity_principal_id" {
  description = "Object ID of the Purview system-assigned managed identity"
  value       = azurerm_purview_account.purview.identity[0].principal_id
}

output "purview_catalog_endpoint" {
  description = "Purview Data Catalog endpoint"
  value       = azurerm_purview_account.purview.catalog_endpoint
}

output "purview_scan_endpoint" {
  description = "Purview Scan endpoint"
  value       = azurerm_purview_account.purview.scan_endpoint
}

output "key_vault_resource_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.purview.id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.purview.vault_uri
}

output "diagnostic_storage_account_id" {
  description = "Resource ID of the diagnostic storage account"
  value       = azurerm_storage_account.diagnostic.id
}

output "private_endpoint_ids" {
  description = "Map of private endpoint name → resource ID"
  value       = { for k, v in azurerm_private_endpoint.endpoints : k => v.id }
}

output "purview_managed_resource_group_id" {
  description = "Resource ID of the Azure-managed Purview resource group (contains managed Storage + Event Hub)"
  value       = azurerm_purview_account.purview.managed_resources[0].resource_group_id
}
