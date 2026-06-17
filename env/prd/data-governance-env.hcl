locals {
  # Subscription for bs-analytics-shared
  subscription_id = "aae6337e-4965-4980-b1e4-d627625694c8" #bs-analytics-shared

  environment = "prod"
  location    = "australiaeast"

  # Naming Convention
  naming_suffixes = ["shrd", "data", "gov"]
  naming_prefixes = ["bs"]

  # Purview account name is still explicit because the shared naming module
  # does not currently define a purview resource type.
  purview_account_name = "bs-ae-shrd-data-gov-pvw"

  # Existing platform dependencies
  existing_vnet_resource_id                     = "/subscriptions/aae6337e-4965-4980-b1e4-d627625694c8/resourceGroups/bs-ae-shrd-data-network-rg/providers/Microsoft.Network/virtualNetworks/bs-ae-shrd-data-network-vnet"
  log_analytics_workspace_resource_id           = "/subscriptions/ad171264-b03d-4b2c-b70b-73bd617778c7/resourceGroups/bs-ae-prd-data-services-rg/providers/Microsoft.OperationalInsights/workspaces/bs-ae-prd-data-services-log"
  adls_storage_account_resource_id              = "/subscriptions/ad171264-b03d-4b2c-b70b-73bd617778c7/resourceGroups/bs-ae-prd-data-anlyt-rg/providers/Microsoft.Storage/storageAccounts/bsaeprddataanlytst"
  databricks_workspace_resource_id              = "/subscriptions/ad171264-b03d-4b2c-b70b-73bd617778c7/resourceGroups/bs-ae-prd-data-anlyt-rg/providers/Microsoft.Databricks/workspaces/bs-ae-prd-data-anlyt-dbw"
  existing_private_dns_zone_subscription_id     = "2077e9d3-7adb-43a1-9d2e-60426bdcdb36" # replace with hub subscription ID
  existing_private_dns_zone_resource_group_name = "bs-ae-prd-connectivity-dnspr-rg"

  # Shared platform defaults
  private_endpoint_subnet_name = "privateendpoints-sn"

  # Cost controls
  enable_purview_budget = false
  monthly_budget_amount = 2000
  budget_start_date     = "2026-05-01T00:00:00Z"
  alert_email_addresses = []

  root_collection_admin_object_ids = [
    # Get OIDs with: az ad group show --group "<group-name>" --query id -o tsv
  ]

  # Feature toggles
  create_private_dns_zones           = false
  create_managed_private_endpoints   = false
  enable_adls_managed_endpoint       = false
  enable_databricks_managed_endpoint = false

  # Key Vault settings
  soft_delete_retention_days = 90

  # Tags
  tags = {
    Application = "Microsoft Purview"
    Environment = "prod"
    Owner       = "Carl Dittloff"
    Criticality = "critical"
    Sensitivity = "confidential"
  }
}