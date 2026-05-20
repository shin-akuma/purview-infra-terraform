# ============================================================
# cost_alerts.tf
# Monthly budget with email alerts at 80% (actual),
# 100% (actual), and 90% (forecasted)
# ============================================================

resource "azurerm_consumption_budget_resource_group" "purview" {
  name              = "budget-purview-${var.environment}-monthly"
  resource_group_id = azurerm_resource_group.purview.id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.alert_email_addresses
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.alert_email_addresses
  }

  notification {
    enabled        = true
    threshold      = 90
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.alert_email_addresses
  }
}
