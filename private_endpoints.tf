# ============================================================
# private_endpoints.tf
# All 6 private endpoints using for_each
# Purview (account + portal), Key Vault, Storage (blob + queue + dfs)
# ============================================================

locals {
  private_endpoints = {
    "${var.purview_account_name}-account" = {
      resource_id   = azurerm_purview_account.purview.id
      subresource   = "account"
      dns_zone_name = "privatelink.purview.azure.com"
    }
    "${var.purview_account_name}-portal" = {
      resource_id   = azurerm_purview_account.purview.id
      subresource   = "portal"
      dns_zone_name = "privatelink.purviewstudio.azure.com"
    }
    "${var.key_vault_name}-vault" = {
      resource_id   = azurerm_key_vault.purview.id
      subresource   = "vault"
      dns_zone_name = "privatelink.vaultcore.azure.net"
    }
    "${var.diagnostic_storage_account_name}-blob" = {
      resource_id   = azurerm_storage_account.diagnostic.id
      subresource   = "blob"
      dns_zone_name = "privatelink.blob.${local.storage_dns_suffix}"
    }
    "${var.diagnostic_storage_account_name}-queue" = {
      resource_id   = azurerm_storage_account.diagnostic.id
      subresource   = "queue"
      dns_zone_name = "privatelink.queue.${local.storage_dns_suffix}"
    }
    "${var.diagnostic_storage_account_name}-dfs" = {
      resource_id   = azurerm_storage_account.diagnostic.id
      subresource   = "dfs"
      dns_zone_name = "privatelink.dfs.${local.storage_dns_suffix}"
    }
  }
}

resource "azurerm_private_endpoint" "endpoints" {
  for_each            = local.private_endpoints
  name                = "pe-${each.key}"
  location            = azurerm_resource_group.purview.location
  resource_group_name = azurerm_resource_group.purview.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id
  tags                = var.tags

  private_service_connection {
    name                           = "pe-${each.key}"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.subresource]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.dns_zone_ids[each.value.dns_zone_name]]
  }
}
