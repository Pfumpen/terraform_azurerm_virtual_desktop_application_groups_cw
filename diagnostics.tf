locals {
  # Defines the diagnostic presets for the Virtual Desktop Application Group.
  diagnostics_presets = {
    basic = {
      logs    = ["Checkpoint", "Error"]
      metrics = ["AllMetrics"]
    },
    detailed = {
      logs    = ["Checkpoint", "Error", "Management"]
      metrics = ["AllMetrics"]
    },
    custom = {
      logs    = var.diagnostics_custom_logs
      metrics = var.diagnostics_custom_metrics
    }
  }

  # Determines the active log and metric categories based on the selected diagnostics_level.
  active_log_categories      = lookup(local.diagnostics_presets, var.diagnostics_level, { logs = [] }).logs
  active_metric_categories   = lookup(local.diagnostics_presets, var.diagnostics_level, { metrics = [] }).metrics
  global_diagnostics_enabled = var.diagnostics_level != "none"
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  # Creates the diagnostic setting if the global switch is not 'none'.
  count = local.global_diagnostics_enabled ? 1 : 0

  name                           = "diag-${var.name}"
  target_resource_id             = azurerm_virtual_desktop_application_group.this.id
  log_analytics_workspace_id     = try(var.diagnostic_settings.log_analytics_workspace_id, null)
  eventhub_authorization_rule_id = try(var.diagnostic_settings.eventhub_authorization_rule_id, null)
  storage_account_id             = try(var.diagnostic_settings.storage_account_id, null)

  # Dynamically enables the specified log categories.
  dynamic "enabled_log" {
    for_each = toset(local.active_log_categories)
    content {
      category = enabled_log.value
    }
  }

  # Dynamically enables the specified metric categories.
  dynamic "enabled_metric" {
    for_each = toset(local.active_metric_categories)
    content {
      category = enabled_metric.value
    }
  }
}
