# ============================================================
# diagnostics.tf
# Diagnostic settings for Purview → Log Analytics + Storage
# Captures audit logs, scan status, data sensitivity events
# ============================================================

resource "azurerm_monitor_diagnostic_setting" "purview" {
  name                       = "diag-${var.purview_account_name}"
  target_resource_id         = azurerm_purview_account.purview.id
  log_analytics_workspace_id = var.log_analytics_workspace_resource_id
  storage_account_id         = azurerm_storage_account.diagnostic.id

  enabled_log {
    category = "AuditEvents"
  }

  enabled_log {
    category = "ScanStatusLogEvent"
  }

  enabled_log {
    category = "DataSensitivityLogEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
