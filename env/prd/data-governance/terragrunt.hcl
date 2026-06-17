# ------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# ------------------------------------------------------------------------------

# Include the root Terragrunt configuration from parent folders.
include {
  path = find_in_parent_folders("root-terragrunt.hcl")
}

# Terraform module source location
terraform {
  source = "${get_repo_root()}"
}

locals {
  # Load shared and environment-level variables
  common_vars           = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  data_governance_vars  = read_terragrunt_config(find_in_parent_folders("data-governance-env.hcl"))

  subscription_id                             = local.data_governance_vars.locals.subscription_id
  environment                                 = local.data_governance_vars.locals.environment
  location                                    = local.common_vars.locals.location
  naming_prefixes                             = local.common_vars.locals.naming_prefixes
  naming_suffixes                             = local.data_governance_vars.locals.naming_suffixes
  purview_account_name                        = local.data_governance_vars.locals.purview_account_name
  existing_vnet_resource_id                   = local.data_governance_vars.locals.existing_vnet_resource_id
  private_endpoint_subnet_name                = local.common_vars.locals.private_endpoint_subnet_name
  log_analytics_workspace_resource_id         = local.data_governance_vars.locals.log_analytics_workspace_resource_id
  adls_storage_account_resource_id            = local.data_governance_vars.locals.adls_storage_account_resource_id
  databricks_workspace_resource_id            = local.data_governance_vars.locals.databricks_workspace_resource_id
  create_private_dns_zones                    = local.common_vars.locals.create_private_dns_zones
  existing_private_dns_zone_subscription_id   = local.data_governance_vars.locals.existing_private_dns_zone_subscription_id
  existing_private_dns_zone_resource_group_name = local.data_governance_vars.locals.existing_private_dns_zone_resource_group_name
  create_managed_private_endpoints            = local.common_vars.locals.create_managed_private_endpoints
  enable_adls_managed_endpoint                = local.common_vars.locals.enable_adls_managed_endpoint
  enable_databricks_managed_endpoint          = local.common_vars.locals.enable_databricks_managed_endpoint
  enable_purview_budget                       = local.common_vars.locals.enable_purview_budget
  monthly_budget_amount                       = local.common_vars.locals.monthly_budget_amount
  budget_start_date                           = local.common_vars.locals.budget_start_date
  alert_email_addresses                       = local.common_vars.locals.alert_email_addresses
  soft_delete_retention_days                  = local.common_vars.locals.soft_delete_retention_days
  root_collection_admin_group_names           = local.data_governance_vars.locals.root_collection_admin_group_names
  tags                                        = local.data_governance_vars.locals.tags
}

inputs = {
  subscription_id                              = local.subscription_id
  environment                                  = local.environment
  location                                     = local.location
  naming_prefixes                              = local.naming_prefixes
  naming_suffixes                              = local.naming_suffixes
  purview_account_name                         = local.purview_account_name
  existing_vnet_resource_id                    = local.existing_vnet_resource_id
  private_endpoint_subnet_name                 = local.private_endpoint_subnet_name
  log_analytics_workspace_resource_id          = local.log_analytics_workspace_resource_id
  adls_storage_account_resource_id             = local.adls_storage_account_resource_id
  databricks_workspace_resource_id             = local.databricks_workspace_resource_id
  create_private_dns_zones                     = local.create_private_dns_zones
  existing_private_dns_zone_subscription_id    = local.existing_private_dns_zone_subscription_id
  existing_private_dns_zone_resource_group_name = local.existing_private_dns_zone_resource_group_name
  create_managed_private_endpoints             = local.create_managed_private_endpoints
  enable_adls_managed_endpoint                 = local.enable_adls_managed_endpoint
  enable_databricks_managed_endpoint           = local.enable_databricks_managed_endpoint
  enable_purview_budget                        = local.enable_purview_budget
  monthly_budget_amount                        = local.monthly_budget_amount
  budget_start_date                            = local.budget_start_date
  alert_email_addresses                        = local.alert_email_addresses
  soft_delete_retention_days                   = local.soft_delete_retention_days
  root_collection_admin_group_names            = local.root_collection_admin_group_names
  tags                                         = local.tags
}