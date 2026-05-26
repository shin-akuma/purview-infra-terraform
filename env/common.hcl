locals {
  # Shared defaults for all environments consuming this Purview stack
  location = "australiaeast"

  # Naming Convention
  # Environment-specific suffixes should be set in the env file.
  naming_prefixes = ["jason", "purview"]

  # Shared platform defaults
  private_endpoint_subnet_name = "snet-private-endpoints"

  # Cost controls
  monthly_budget_amount = 2000
  budget_start_date     = "2026-05-01T00:00:00Z"
  alert_email_addresses = [
    "platform-alerts@example.com",
    "data-governance@example.com",
  ]

  # Feature toggles
  create_private_dns_zones           = false
  create_managed_private_endpoints   = false
  enable_adls_managed_endpoint       = false
  enable_databricks_managed_endpoint = false

  # Key Vault settings
  soft_delete_retention_days = 90

  # Shared tags
  tags = {
    project     = "jason-super-purview"
    managed_by  = "arinco"
    cost_center = "data-governance"
    work_order  = "jason-super-data-governance-implementation"
  }
}