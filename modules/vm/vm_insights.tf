
resource "azurerm_virtual_machine_extension" "monitor_agent" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.xroadvm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.21"

  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_monitor_data_collection_rule_association" "association" {
  name                    = "MonitorVM"
  target_resource_id      = azurerm_linux_virtual_machine.xroadvm.id
  data_collection_rule_id = var.data_collection_rule_id
}
