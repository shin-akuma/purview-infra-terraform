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
  value       = module.purview_account.name
}

output "purview_resource_id" {
  description = "Resource ID of the Purview account"
  value       = module.purview_account.resource_id
}

output "purview_managed_identity_principal_id" {
  description = "Object ID of the Purview system-assigned managed identity"
  value       = module.purview_account.managed_identity_principal_id
}

output "purview_catalog_endpoint" {
  description = "Purview Data Catalog endpoint"
  value       = module.purview_account.catalog_endpoint
}

output "purview_scan_endpoint" {
  description = "Purview Scan endpoint"
  value       = module.purview_account.scan_endpoint
}

output "key_vault_resource_id" {
  description = "Resource ID of the Key Vault"
  value       = module.key_vault.resource_id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = "https://${module.key_vault.name}.vault.azure.net/"
}

output "diagnostic_storage_account_id" {
  description = "Resource ID of the diagnostic storage account"
  value       = module.diagnostic_storage.resource_id
}

output "private_endpoint_ids" {
  description = "Map of private endpoint key -> resource ID"
  value       = { for k, v in module.private_endpoints : k => v.resource_id }
}

output "purview_managed_resource_group_id" {
  description = "Resource ID of the Azure-managed Purview resource group (contains managed Storage + Event Hub)"
  value       = module.purview_account.managed_resource_group_id
}

output "managed_private_endpoints_created" {
  description = "List of managed private endpoints created"
  value       = module.managed_private_endpoints.managed_private_endpoints_created
}
