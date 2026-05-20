# ============================================================
# managed_private_endpoints.tf
# Managed Private Endpoints from Purview to data sources
# Purview initiates connections; targets must approve
# ============================================================

# ============================================================
# Variables for Managed Private Endpoint Configuration
# ============================================================

variable "create_managed_private_endpoints" {
  description = "Whether to create managed private endpoints from Purview to data sources"
  type        = bool
  default     = false
}

variable "enable_adls_managed_endpoint" {
  description = "Create a managed private endpoint from Purview to ADLS Gen2 storage"
  type        = bool
  default     = false
}

variable "enable_databricks_managed_endpoint" {
  description = "Create a managed private endpoint from Purview to Databricks workspace"
  type        = bool
  default     = false
}

# ============================================================
# Managed Private Endpoint to ADLS Gen2 Storage
# ============================================================

# NOTE: The azurerm provider does not yet have a native resource for Purview managed
# private endpoints. This is a workaround using a local-exec provisioner to create
# the managed private endpoint request via Azure CLI.
#
# Alternative approaches:
# 1. Use azurerm_resource_group_template_deployment with ARM template
# 2. Use terraform-provider-azapi for more advanced ARM API operations
# 3. Manual creation via Azure Portal / PowerShell after Terraform apply

resource "null_resource" "adls_managed_endpoint" {
  count = var.create_managed_private_endpoints && var.enable_adls_managed_endpoint ? 1 : 0

  triggers = {
    purview_account_name = azurerm_purview_account.purview.name
    resource_group_name  = azurerm_resource_group.purview.name
    adls_resource_id     = var.adls_storage_account_resource_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      az purview account managed-resource create-private-endpoint \
        --resource-group "${azurerm_resource_group.purview.name}" \
        --account-name "${azurerm_purview_account.purview.name}" \
        --endpoint-name "pe-${var.purview_account_name}-adls" \
        --api-type "StorageAccount" \
        --target-resource-id "${var.adls_storage_account_resource_id}"
    EOT
  }

  depends_on = [azurerm_purview_account.purview]
}

# ============================================================
# Managed Private Endpoint to Databricks Workspace
# ============================================================

resource "null_resource" "databricks_managed_endpoint" {
  count = var.create_managed_private_endpoints && var.enable_databricks_managed_endpoint ? 1 : 0

  triggers = {
    purview_account_name        = azurerm_purview_account.purview.name
    resource_group_name         = azurerm_resource_group.purview.name
    databricks_resource_id      = var.databricks_workspace_resource_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      az purview account managed-resource create-private-endpoint \
        --resource-group "${azurerm_resource_group.purview.name}" \
        --account-name "${azurerm_purview_account.purview.name}" \
        --endpoint-name "pe-${var.purview_account_name}-databricks" \
        --api-type "Databricks" \
        --target-resource-id "${var.databricks_workspace_resource_id}"
    EOT
  }

  depends_on = [azurerm_purview_account.purview]
}

# ============================================================
# Output: Managed Private Endpoint Status
# ============================================================

output "managed_private_endpoints_created" {
  description = "List of managed private endpoints created"
  value = concat(
    var.enable_adls_managed_endpoint ? ["pe-${var.purview_account_name}-adls"] : [],
    var.enable_databricks_managed_endpoint ? ["pe-${var.purview_account_name}-databricks"] : []
  )
}
