resource "azurerm_monitor_metric_alert" "avail_mem_bytes" {
  name                = "Available Memory Bytes - vm-xroad-securityserver-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-1.vmid,
    module.xroad-securityserver-2[0].vmid
  ]
  description         = "Memory less than 1GB"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1000000000
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

resource "azurerm_monitor_metric_alert" "data_disk_iops_consumed_percentage" {
  name                = "Data Disk IOPS Consumed Percentage - vm-xroad-securityserver-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-1.vmid,
    module.xroad-securityserver-2[0].vmid
  ]
  description         = "Alert when Data Disk IOPS Consumed Percentage exceeds 95%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Data Disk IOPS Consumed Percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 95
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

resource "azurerm_monitor_metric_alert" "network_in_total_1" {
  name                = "Network In Total - vm-xroad-securityserver-1-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-1.vmid,
  ]
  description         = "Alert when Network In Total exceeds 500 GB"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network In Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 500000000000 # This is in bytes, which equals 500 GB
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

resource "azurerm_monitor_metric_alert" "network_in_total_2" {
  name                = "Network In Total - vm-xroad-securityserver-2-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-2[0].vmid
  ]
  description         = "Alert when Network In Total exceeds 500 GB"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network In Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 500000000000 # This is in bytes, which equals 500 GB
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

resource "azurerm_monitor_metric_alert" "network_out_total_1" {
  name                = "Network Out Total - vm-xroad-securityserver-1-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-1.vmid,
  ]
  description         = "Alert when Network Out Total exceeds 200 GB"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network Out Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 200000000000  # This is in bytes, which equals 200 GB
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

resource "azurerm_monitor_metric_alert" "network_out_total_2" {
  name                = "Network Out Total - vm-xroad-securityserver-2-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-2[0].vmid
  ]
  description         = "Alert when Network Out Total exceeds 200 GB"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network Out Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 200000000000  # This is in bytes, which equals 200 GB
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

resource "azurerm_monitor_metric_alert" "os_disk_iops_consumed_percentage" {
  name                = "OS Disk IOPS Consumed Percentage - vm-xroad-securityserver-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-1.vmid,
    module.xroad-securityserver-2[0].vmid
  ]
  description         = "Alert when OS Disk IOPS Consumed Percentage exceeds 95%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk IOPS Consumed Percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 95
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

resource "azurerm_monitor_metric_alert" "percentage_cpu" {
  name                = "Percentage CPU - vm-xroad-securityserver-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-1.vmid,
    module.xroad-securityserver-2[0].vmid
  ]
  description         = "Alert when Percentage CPU exceeds 80%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
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

resource "azurerm_monitor_metric_alert" "vm_availability" {
  name                = "VM Availability - vm-xroad-securityserver-prd"
  resource_group_name = azurerm_resource_group.xroad.name
  target_resource_location = var.location
  target_resource_type = "Microsoft.Compute/virtualMachines"
  scopes              = [
    module.xroad-securityserver-1.vmid,
    module.xroad-securityserver-2[0].vmid
  ]
  description         = "Alert when VM Availability is less than 1"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
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
