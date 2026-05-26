# ============================================================
# variables.tf
# All input variables — mirror of main.bicepparam
# ============================================================

variable "subscription_id" {
  description = "Azure subscription ID to deploy into"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod"
  }
}

variable "location" {
  description = "Primary Azure region for all resources"
  type        = string
  default     = "australiaeast"
}

variable "naming_prefixes" {
  description = "Ordered prefixes passed to the naming conventions module"
  type        = list(string)
}

variable "naming_suffixes" {
  description = "Ordered suffixes passed to the naming conventions module"
  type        = list(string)
}

variable "purview_account_name" {
  description = "Name for the Purview account — must be globally unique"
  type        = string
}

variable "existing_vnet_resource_id" {
  description = "Resource ID of the existing VNet to deploy private endpoints into"
  type        = string
}

variable "private_endpoint_subnet_name" {
  description = "Name of the subnet within the VNet for private endpoints"
  type        = string
}

variable "log_analytics_workspace_resource_id" {
  description = "Resource ID of the existing Log Analytics Workspace for diagnostics"
  type        = string
}

variable "adls_storage_account_resource_id" {
  description = "Resource ID of the existing ADLS Gen2 storage account that Purview will scan"
  type        = string
}

variable "databricks_workspace_resource_id" {
  description = "Resource ID of the existing Databricks workspace that Purview will scan"
  type        = string
}

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

variable "create_private_dns_zones" {
  description = "Whether to create new Private DNS Zones (false = use existing zones in hub subscription)"
  type        = bool
  default     = true
}

variable "existing_private_dns_zone_resource_group_name" {
  description = "Resource group name containing existing Private DNS Zones (only used when create_private_dns_zones = false)"
  type        = string
  default     = ""
}

variable "existing_private_dns_zone_subscription_id" {
  description = "Subscription ID containing existing Private DNS Zones when they live outside the deployment subscription"
  type        = string
  default     = null
  nullable    = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget in AUD for Purview resources"
  type        = number
  default     = 2000
}

variable "budget_start_date" {
  description = "Start date for the monthly budget (ISO 8601, first day of the month e.g. 2026-06-01T00:00:00Z)"
  type        = string
  default     = "2026-05-01T00:00:00Z"
}

variable "alert_email_addresses" {
  description = "Email addresses to notify on cost threshold breaches"
  type        = list(string)
  default     = []
}

variable "soft_delete_retention_days" {
  description = "Key Vault soft-delete retention in days (7–90)"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    environment = "prod"
    project     = "jason-super-purview"
    managed_by  = "arinco"
    cost_center = "data-governance"
    work_order  = "jason-super-data-governance-implementation"
  }
}
