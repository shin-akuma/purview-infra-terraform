locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  # Subscription for Jason Super production
  subscription_id = "00000000-0000-0000-0000-000000000000" # replace with prod subscription ID

  environment = "prod"

  # Naming Convention
  naming_suffixes = ["prod"]

  # Purview account name is still explicit because the shared naming module
  # does not currently define a purview resource type.
  purview_account_name = "pvw-jason-prod-001"

  # Existing platform dependencies
  existing_vnet_resource_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod"
  log_analytics_workspace_resource_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring-prod/providers/Microsoft.OperationalInsights/workspaces/law-jason-prod"
  adls_storage_account_resource_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data-prod/providers/Microsoft.Storage/storageAccounts/stjasondatalakeprod"
  databricks_workspace_resource_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data-prod/providers/Microsoft.Databricks/workspaces/dbw-jason-prod"
  existing_private_dns_zone_subscription_id    = "11111111-1111-1111-1111-111111111111" # replace with hub subscription ID
  existing_private_dns_zone_resource_group_name = "rg-network-prod"

  # Environment-specific tags
  tags = merge(local.common.locals.tags, {
    environment = "prod"
  })
}