resource "azurerm_monitor_metric_alert" "db_avail_mem_bytes" {
  name                = "Percentage Memory - psql-watf-xroad-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.DBforPostgreSQL/flexibleServers"
  scopes              = [
    azurerm_postgresql_flexible_server.psql.id
  ]
  description         = "Alert when Percentage Memory exceeds 90%"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "memory_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = var.actiongroup_id
  }

  severity    = 2
  frequency   = "PT15M"
  window_size = "PT15M"
  enabled     = true

  tags = merge(var.tags, var.envTags)

  count = var.env == "prd" ? 1 : 0
}

resource "azurerm_monitor_metric_alert" "db_percentage_cpu" {
  name                = "Percentage CPU - psql-watf-xroad-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.DBforPostgreSQL/flexibleServers"
  scopes              = [
    azurerm_postgresql_flexible_server.psql.id
  ]
  description         = "Alert when Percentage CPU exceeds 80%"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = var.actiongroup_id
  }

  severity    = 2
  frequency   = "PT5M"
  window_size = "PT5M"
  enabled     = true

  tags = merge(var.tags, var.envTags)

  count = var.env == "prd" ? 1 : 0
}

resource "azurerm_monitor_metric_alert" "db_availability" {
  name                = "PostgreSQL Availability - psql-watf-xroad-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.DBforPostgreSQL/flexibleServers"
  scopes              = [
    azurerm_postgresql_flexible_server.psql.id
  ]
  description         = "Alert when PostgreSQL Availability is less than 1"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "is_db_alive"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = var.actiongroup_id
  }

  severity    = 2
  frequency   = "PT5M"
  window_size = "PT5M"
  enabled     = true

  tags = merge(var.tags, var.envTags)

  count = var.env == "prd" ? 1 : 0
}
