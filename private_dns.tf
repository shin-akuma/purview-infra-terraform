# ============================================================
# private_dns.tf
# Private DNS Zones + VNet links
# Conditional: create new zones OR reference existing hub zones
# ============================================================

# ---- Create new zones (when create_private_dns_zones = true) ---

resource "azurerm_private_dns_zone" "zones" {
  for_each            = var.create_private_dns_zones ? local.private_dns_zone_names : toset([])
  name                = each.key
  resource_group_name = azurerm_resource_group.purview.name
  tags                = var.tags
}

# VNet link for each newly created zone
resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each              = var.create_private_dns_zones ? local.private_dns_zone_names : toset([])
  name                  = "link-${local.vnet_name}"
  resource_group_name   = azurerm_resource_group.purview.name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.key].name
  virtual_network_id    = var.existing_vnet_resource_id
  registration_enabled  = false
  tags                  = var.tags
}

# ---- Reference existing hub zones (when create_private_dns_zones = false) ---

data "azurerm_private_dns_zone" "existing" {
  for_each            = var.create_private_dns_zones ? toset([]) : local.private_dns_zone_names
  name                = each.key
  resource_group_name = var.existing_private_dns_zone_resource_group_name
}

# ---- Resolved zone IDs (used by private_endpoints.tf) ----------

locals {
  dns_zone_ids = {
    for name in local.private_dns_zone_names :
    name => var.create_private_dns_zones ? azurerm_private_dns_zone.zones[name].id : data.azurerm_private_dns_zone.existing[name].id
  }
}
