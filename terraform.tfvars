# ============================================================
# terraform.tfvars
# Production variable values for Brighter Super Purview
# Update all REPLACE_ values before running terraform plan
# ============================================================

subscription_id = "REPLACE_subscription-guid"

environment = "prod"
location    = "australiaeast"

purview_account_name             = "pvw-bsup-prod-001"
key_vault_name                   = "kv-bsup-purview-prod"
diagnostic_storage_account_name  = "stbsuppurviewprod001"

# REPLACE_ with actual resource IDs from Brighter Super landing zone
existing_vnet_resource_id = "REPLACE_/subscriptions/{subscriptionId}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnetName}"

private_endpoint_subnet_name = "snet-purview"

log_analytics_workspace_resource_id = "REPLACE_/subscriptions/{subscriptionId}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{lawName}"

adls_storage_account_resource_id = "REPLACE_/subscriptions/{subscriptionId}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{adlsName}"

databricks_workspace_resource_id = "REPLACE_/subscriptions/{subscriptionId}/resourceGroups/{rg}/providers/Microsoft.Databricks/workspaces/{dbwName}"

# Set to false if Private DNS Zones already exist in a central hub subscription
create_private_dns_zones = true

# Only required when create_private_dns_zones = false
existing_private_dns_zone_resource_group_name = ""

# Managed Private Endpoints — enable if data sources block public access
create_managed_private_endpoints = false
enable_adls_managed_endpoint      = false
enable_databricks_managed_endpoint = false

monthly_budget_amount = 2000

# First day of the current deployment month — update when redeploying
budget_start_date = "2026-05-01T00:00:00Z"

alert_email_addresses = [
  "cdittloff@lgiasuper.com.au",
  # Add additional recipients here
]

soft_delete_retention_days = 90

tags = {
  environment  = "prod"
  project      = "brighter-super-purview"
  managed_by   = "arinco"
  cost_center  = "data-governance"
  work_order   = "brighter-super-data-governance-implementation"
}
