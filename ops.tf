resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-xroad"
  location            = var.location
  resource_group_name = azurerm_resource_group.ops.name
  sku                 = "PerGB2018"

  tags = local.tags
}

resource "azurerm_log_analytics_workspace_table" "activityLogs" {
  workspace_id            = azurerm_log_analytics_workspace.law.id
  name                    = "AzureActivity"
  retention_in_days       = 90
  total_retention_in_days = 730
}

resource "azurerm_monitor_action_group" "ag" {
  name                = "ag-xroad"
  resource_group_name = azurerm_resource_group.ops.name
  short_name          = "xroad"

  email_receiver {
    name = var.actiongroup_email
    email_address = var.actiongroup_email
    use_common_alert_schema = true
  }
}

resource "azurerm_recovery_services_vault" "rsv" {
  name                = "rsv-xroad"
  resource_group_name = azurerm_resource_group.ops.name
  location            = var.location
  sku                 = "Standard"

  monitoring {
    # Classic alert settings
    alerts_for_critical_operation_failures_enabled = false    
  }
}

resource "azurerm_monitor_alert_processing_rule_action_group" "example" {
  name                 = "alrtrule-rsv-xroad"
  resource_group_name = azurerm_resource_group.ops.name
  scopes               = [azurerm_recovery_services_vault.rsv.id]
  add_action_group_ids = [azurerm_monitor_action_group.ag.id]

  condition {
    severity {
      operator = "Equals"
      values   = ["Sev0", "Sev1"]
    }
  }

  tags = local.tags
}

resource "azurerm_backup_policy_vm" "xroad" {
  name                = "bkpol-xroad"
  resource_group_name = azurerm_resource_group.ops.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  policy_type = "V2"
  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "01:00"
  }

  retention_daily {
    count = 14
  }

  retention_monthly {
    count    = 6
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "dcr-xroad"
  location            = var.location
  resource_group_name = azurerm_resource_group.ops.name

  tags = local.tags

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = azurerm_log_analytics_workspace.law.name
    }
  }

  data_flow {
    streams = [
      "Microsoft-InsightsMetrics",
      "Microsoft-Syslog"
    ]
    destinations = [
      azurerm_log_analytics_workspace.law.name
    ]
  }

  data_sources {
    performance_counter {
      name                          = "VMInsightsPerfCounters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
    }
    syslog {
      name    = "sysLogsDataSource"
      streams = ["Microsoft-Syslog"]
      facility_names = [
        "auth",
        "authpriv",
        "cron",
        "daemon",
        "mark",
        "kern",
        "local0",
        "local1",
        "local2",
        "local3",
        "local4",
        "local5",
        "local6",
        "local7",
        "lpr",
        "mail",
        "news",
        "syslog",
        "user",
        "uucp"
      ]
      log_levels = [
        "Debug",
        "Info",
        "Notice",
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency"
      ]
    }
  }

  # Seems to be required to ensure law has Microsoft-InsightsMetrics table ready
  depends_on = [ azurerm_log_analytics_workspace.law ]
}
