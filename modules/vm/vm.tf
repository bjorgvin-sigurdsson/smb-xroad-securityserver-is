resource "azurerm_public_ip" "pip" {
  name                = "pip-xroad-securityserver-${var.zone}-${var.env}"
  resource_group_name = var.xroad_resource_group_name
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = "${var.organization_dns_fragment}-xroad-${var.zone}-${var.env}"
  sku                 = "Standard"

  tags = merge(var.tags, var.envTags)
}

resource "azurerm_network_interface" "main" {
  name                = "nic-xroad-securityserver-${var.zone}-${var.env}"
  location            = var.location
  resource_group_name = var.xroad_resource_group_name

  ip_configuration {
    name                          = "default"
    subnet_id                     = var.subnet_xroadvm_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = merge(var.tags, var.envTags)
}

resource "azurerm_linux_virtual_machine" "xroadvm" {
  name                  = "vm-xroad-securityserver-${var.zone}-${var.env}"
  location              = var.location
  resource_group_name   = var.xroad_resource_group_name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = var.vm_sku
  secure_boot_enabled   = true
  vtpm_enabled          = true

  zone = var.zone

  admin_username = var.vm_username
  dynamic "admin_ssh_key" {
    for_each = var.ssh_pubkey != null ? [var.ssh_pubkey] : []
    content {
      username   = var.vm_username
      public_key = admin_ssh_key.value
    }
  }
  disable_password_authentication = var.ssh_pubkey != null ? true : false
  admin_password                  = var.ssh_pubkey == null && var.vm_password != null ? var.vm_password : null

  custom_data = base64encode(local.vm_bash_script)

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
    name                 = "osdisk-xroad-securityserver-${var.zone}-${var.env}"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  identity {
    type = "SystemAssigned"
  }

  # Allow reruns of terraform without recreating the VM
  # If lifecycle is not set, the VM will be destroyed and recreated on every apply
  # despite the custom_data being unchanged
  lifecycle {
    ignore_changes = [
      custom_data,
    ]
  }

  tags = merge(var.tags, var.envTags)
}

# Auto shutdown dev instance
resource "azurerm_dev_test_global_vm_shutdown_schedule" "example" {
  virtual_machine_id = azurerm_linux_virtual_machine.xroadvm.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = "2300"
  timezone              = "UTC"

  notification_settings {
    enabled         = false
  }

  count = var.env == "dev" ? 1 : 0
}

# Backups on prd
resource "azurerm_backup_protected_vm" "xroad_vm_protection" {
  recovery_vault_name = var.rsv_name
  resource_group_name = var.ops_resource_group_name
  source_vm_id        = azurerm_linux_virtual_machine.xroadvm.id
  backup_policy_id    = var.rsv_policy_id

  count = var.env == "prd" ? 1 : 0
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                         = "CustomScript"
  virtual_machine_id   = azurerm_linux_virtual_machine.xroadvm.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"

  depends_on = [ azurerm_virtual_machine_extension.monitor_agent ]
  # Take advantage of the custom scripts protected section for secret handling
  settings = <<SETTINGS
  {
    "commandToExecute": "sed -i 's/XROAD_WEBADMIN_PASSWORD/${var.xrd_webadmin_password}/' /opt/xroad/custom_script.sh && sed -i 's/POSTGRESQL_PASSWORD/${var.psql_password}/' /opt/xroad/custom_script.sh && /opt/xroad/custom_script.sh"
  }
SETTINGS
}

output "vmid" {
  value = azurerm_linux_virtual_machine.xroadvm.id
}
