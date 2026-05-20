# ============================================================
# main.tf
# Locals, data sources, Resource Group, NSG
# ============================================================

# ============================================================
# Locals — parse resource IDs passed as variables
# ============================================================

locals {
  # Parse VNet resource ID: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{name}
  vnet_parts               = split("/", var.existing_vnet_resource_id)
  vnet_resource_group_name = local.vnet_parts[4]
  vnet_name                = local.vnet_parts[8]

  # DNS suffix — static for Azure public cloud; update for sovereign clouds
  storage_dns_suffix = "core.windows.net"

  # All Private DNS zone names required for this solution
  private_dns_zone_names = toset([
    "privatelink.purview.azure.com",
    "privatelink.purviewstudio.azure.com",
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.${local.storage_dns_suffix}",
    "privatelink.queue.${local.storage_dns_suffix}",
    "privatelink.dfs.${local.storage_dns_suffix}",
  ])

  resource_group_name = "rg-bsup-purview-${var.environment}"
  nsg_name            = "nsg-bsup-purview-${var.environment}"
}

# ============================================================
# Data Sources — existing infrastructure
# ============================================================

# Existing subnet in the landing zone VNet
data "azurerm_subnet" "private_endpoint" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = local.vnet_resource_group_name
  virtual_network_name = local.vnet_name
}

# ============================================================
# Resource Group
# ============================================================

resource "azurerm_resource_group" "purview" {
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

# ============================================================
# Network Security Group
# Applied to the private endpoint subnet — associate manually
# or via azurerm_subnet_network_security_group_association
# ============================================================

resource "azurerm_network_security_group" "purview" {
  name                = local.nsg_name
  location            = azurerm_resource_group.purview.location
  resource_group_name = azurerm_resource_group.purview.name
  tags                = var.tags

  # ---- Inbound -----------------------------------------------

  security_rule {
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
  }

  # ---- Outbound -----------------------------------------------

  security_rule {
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
  }

  security_rule {
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
  }

  security_rule {
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
  }

  security_rule {
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
  }

  security_rule {
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
  }

  security_rule {
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
  }

  security_rule {
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
}
