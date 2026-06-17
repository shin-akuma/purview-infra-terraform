# ============================================================
# main.tf
# Root orchestration only: data sources, locals, remote modules
# ============================================================

locals {
  # Parse VNet resource ID: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{name}
  vnet_parts               = split("/", var.existing_vnet_resource_id)
  vnet_resource_group_name = local.vnet_parts[4]
  vnet_name                = local.vnet_parts[8]

  storage_dns_suffix = "core.windows.net"

  private_dns_zone_names = toset([
    "privatelink.purview.azure.com",
    "privatelink.purviewstudio.azure.com",
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.${local.storage_dns_suffix}",
    "privatelink.queue.${local.storage_dns_suffix}",
    "privatelink.dfs.${local.storage_dns_suffix}",
  ])

  private_endpoints = {
    purview_account = {
      target_resource_name = var.purview_account_name
      target_resource_id   = module.purview_account.resource_id
      subresource          = "account"
      dns_zone_name        = "privatelink.purview.azure.com"
    }
    purview_portal = {
      target_resource_name = var.purview_account_name
      target_resource_id   = module.purview_account.resource_id
      subresource          = "portal"
      dns_zone_name        = "privatelink.purviewstudio.azure.com"
    }
    key_vault = {
      target_resource_name = module.naming_convention_purview.naming_output.key_vault.resource_name
      target_resource_id   = module.key_vault.resource_id
      subresource          = "vault"
      dns_zone_name        = "privatelink.vaultcore.azure.net"
    }
    storage_blob = {
      target_resource_name = module.naming_convention_purview.naming_output.storage_account.resource_name
      target_resource_id   = module.diagnostic_storage.resource_id
      subresource          = "blob"
      dns_zone_name        = "privatelink.blob.${local.storage_dns_suffix}"
    }
    storage_queue = {
      target_resource_name = module.naming_convention_purview.naming_output.storage_account.resource_name
      target_resource_id   = module.diagnostic_storage.resource_id
      subresource          = "queue"
      dns_zone_name        = "privatelink.queue.${local.storage_dns_suffix}"
    }
    storage_dfs = {
      target_resource_name = module.naming_convention_purview.naming_output.storage_account.resource_name
      target_resource_id   = module.diagnostic_storage.resource_id
      subresource          = "dfs"
      dns_zone_name        = "privatelink.dfs.${local.storage_dns_suffix}"
    }
  }

  dns_zone_ids = {
    for name in local.private_dns_zone_names :
    name => var.create_private_dns_zones ? module.private_dns_zones[name].resource_id : data.azurerm_private_dns_zone.existing[name].id
  }
}

# Existing subnet in the landing zone VNet
# Existing Private DNS zones (when create_private_dns_zones = false)
data "azurerm_subnet" "private_endpoint" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = local.vnet_resource_group_name
  virtual_network_name = local.vnet_name
}

data "azurerm_private_dns_zone" "existing" {
  provider            = azurerm.hub
  for_each            = var.create_private_dns_zones ? toset([]) : local.private_dns_zone_names
  name                = each.key
  resource_group_name = var.existing_private_dns_zone_resource_group_name
}

resource "azurerm_resource_provider_registration" "purview" {
  name = "Microsoft.Purview"
}

resource "azurerm_resource_group" "purview" {
  name     = module.naming_convention_purview.naming_output.resource_group.resource_name
  location = var.location
  tags     = var.tags

  depends_on = [azurerm_resource_provider_registration.purview]
}

module "purview_account" {
  source = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/purview/accounts?ref=main"

  name                        = var.purview_account_name
  resource_group_name         = azurerm_resource_group.purview.name
  location                    = azurerm_resource_group.purview.location
  managed_resource_group_name = "${var.purview_account_name}-managed-rg"
  tags                        = var.tags
}

module "nsg" {
  source = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/network/network-security-groups?ref=main"

  name                = module.naming_convention_purview.naming_output.nsg.resource_name
  location            = azurerm_resource_group.purview.location
  resource_group_name = azurerm_resource_group.purview.name
  tags                = var.tags
  subnet_id           = [] # Not attached — privateendpoints-sn is a shared subnet; attach only if a dedicated Purview subnet is provisioned

  security_rules = [
    {
      name                       = "Deny-Inbound-All"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all inbound traffic not explicitly permitted"
    },
    {
      name                       = "Allow-Out-HTTPS-AAD"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureActiveDirectory"
      description                = "Purview token acquisition from Azure Active Directory"
    },
    {
      name                       = "Allow-Out-HTTPS-AzureMonitor"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureMonitor"
      description                = "Purview diagnostic telemetry to Azure Monitor"
    },
    {
      name                       = "Allow-Out-HTTPS-Storage"
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Storage"
      description                = "Purview managed storage (ingestion and scan metadata)"
    },
    {
      name                       = "Allow-Out-HTTPS-EventHub"
      priority                   = 130
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "EventHub"
      description                = "Purview managed Event Hub for scan notifications"
    },
    {
      name                       = "Allow-Out-HTTPS-KeyVault"
      priority                   = 140
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureKeyVault"
      description                = "Key Vault secret retrieval for scan credentials"
    },
    {
      name                       = "Allow-Out-HTTPS-VNet"
      priority                   = 150
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Intra-VNet HTTPS for private endpoint connectivity"
    },
    {
      name                       = "Deny-Outbound-All"
      priority                   = 4096
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all outbound traffic not explicitly permitted"
    }
  ]

  depends_on = [azurerm_resource_group.purview]
}

module "key_vault" {
  source = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/key-vault/vault?ref=main"

  name                          = module.naming_convention_purview.naming_output.key_vault.resource_name
  location                      = azurerm_resource_group.purview.location
  resource_group_name           = azurerm_resource_group.purview.name
  tags                          = var.tags
  rbac_authorization_enabled    = true
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = true
  public_network_access_enabled = false

  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false

  network_acls = [
    {
      default_action = "Deny"
      bypass         = "AzureServices"
      ip_rules       = []
    }
  ]

  depends_on = [azurerm_resource_group.purview]
}

module "diagnostic_storage" {
  source = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/storage/storage-account?ref=main"

  name                            = module.naming_convention_purview.naming_output.storage_account.resource_name
  resource_group_name             = azurerm_resource_group.purview.name
  location                        = azurerm_resource_group.purview.location
  tags                            = var.tags
  sku                             = "Standard_GRS"
  account_kind                    = "StorageV2"
  access_tier                     = "Hot"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = false

  delete_retention_policy_days           = 90
  container_delete_retention_policy_days = 90

  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  depends_on = [azurerm_resource_group.purview]
}

module "private_dns_zones" {
  for_each = var.create_private_dns_zones ? local.private_dns_zone_names : toset([])
  source   = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/network/private-dns-zones?ref=main"

  name                = each.key
  resource_group_name = azurerm_resource_group.purview.name
  tags                = var.tags

  virtual_network_links = [
    {
      virtual_network_link_name = "link-${local.vnet_name}"
      virtual_network_id        = var.existing_vnet_resource_id
      registration_enabled      = false
      tags                      = var.tags
    }
  ]

  depends_on = [azurerm_resource_group.purview]
}

module "private_endpoints" {
  for_each = local.private_endpoints
  source   = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/network/private-endpoints?ref=main"

  target_resource_name     = each.value.target_resource_name
  target_resource_id       = each.value.target_resource_id
  target_sub_resource_type = [each.value.subresource]

  location            = azurerm_resource_group.purview.location
  resource_group_name = azurerm_resource_group.purview.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id
  tags                = var.tags

  private_dns_zone_ids = [local.dns_zone_ids[each.value.dns_zone_name]]

  depends_on = [
    module.purview_account,
    module.key_vault,
    module.diagnostic_storage,
    module.private_dns_zones
  ]
}

module "purview_diagnostics" {
  source = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/monitor/diagnostic-settings?ref=main"

  location             = azurerm_resource_group.purview.location
  resource_group_name  = azurerm_resource_group.purview.name
  target_resource_name = var.purview_account_name
  target_resource_id   = module.purview_account.resource_id

  diagnostic_storage_account_id         = module.diagnostic_storage.resource_id
  diagnostic_log_analytics_workspace_id = var.log_analytics_workspace_resource_id

  diagnostic_metrics = ["AllMetrics"]
}

resource "azurerm_role_assignment" "purview_subscription_reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = module.purview_account.managed_identity_principal_id
  description          = "Purview MI - subscription-level Reader for resource enumeration"
}

resource "azurerm_role_assignment" "purview_kv_secrets_user" {
  scope                = module.key_vault.resource_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.purview_account.managed_identity_principal_id
  description          = "Purview MI - Key Vault Secrets User for scan credential retrieval"
}

resource "azurerm_role_assignment" "purview_diagnostic_storage_contributor" {
  scope                = module.diagnostic_storage.resource_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.purview_account.managed_identity_principal_id
  description          = "Purview MI - Storage Blob Data Contributor on diagnostic storage"
}

resource "azurerm_role_assignment" "purview_adls_reader" {
  scope                = var.adls_storage_account_resource_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.purview_account.managed_identity_principal_id
  description          = "Purview MI - Storage Blob Data Reader on ADLS Gen2 for scanning"
}

resource "azurerm_role_assignment" "purview_databricks_reader" {
  scope                = var.databricks_workspace_resource_id
  role_definition_name = "Reader"
  principal_id         = module.purview_account.managed_identity_principal_id
  description          = "Purview MI - Reader on Databricks workspace for Unity Catalog connector"
}

module "purview_budget" {
  count  = var.enable_purview_budget ? 1 : 0
  source = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/cost-management/budgets?ref=main"

  name              = "budget-purview-${var.environment}-monthly"
  amount            = var.monthly_budget_amount
  resource_group_id = azurerm_resource_group.purview.id
  time_grain        = "Monthly"

  time_period = {
    start_date = var.budget_start_date
  }

  notifications = {
    actual_80 = {
      enabled        = true
      threshold      = 80
      operator       = "GreaterThan"
      contact_emails = var.alert_email_addresses
    }
    actual_100 = {
      enabled        = true
      threshold      = 100
      operator       = "GreaterThan"
      contact_emails = var.alert_email_addresses
    }
    forecast_90 = {
      enabled        = true
      threshold      = 90
      operator       = "GreaterThan"
      contact_emails = var.alert_email_addresses
    }
  }
}

module "managed_private_endpoints" {
  source = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/purview/managed-private-endpoints?ref=main"

  create_managed_private_endpoints   = var.create_managed_private_endpoints
  enable_adls_managed_endpoint       = var.enable_adls_managed_endpoint
  enable_databricks_managed_endpoint = var.enable_databricks_managed_endpoint

  resource_group_name              = azurerm_resource_group.purview.name
  purview_account_name             = module.purview_account.name
  adls_storage_account_resource_id = var.adls_storage_account_resource_id
  databricks_workspace_resource_id = var.databricks_workspace_resource_id

  depends_on = [module.purview_account]
}

# --------------------------------------------------------
# Root collection admins
# --------------------------------------------------------
resource "azapi_resource_action" "purview_root_collection_admin" {
  for_each    = toset(var.root_collection_admin_object_ids)
  type        = "Microsoft.Purview/accounts@2021-07-01"
  resource_id = module.purview_account.resource_id
  action      = "addRootCollectionAdmin"
  method      = "POST"

  body = {
    objectId = each.value
  }

  depends_on = [module.purview_account]
}
