terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.91.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  # Used during initial creation of rg and timestamp
  opsTags = {
    CreateDate = timestamp()
    CreatedBy = var.username
  }
  tags = {
    CreateDate = azurerm_resource_group.ops.tags.CreateDate
    CreatedBy = var.username
  }
}

resource "azurerm_resource_group" "ops" {
  name = "rg-xroad-ops"
  location = var.location

  tags = local.opsTags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_diagnostic_setting" "activityLogs" {
  name                       = "ActivityLogs"
  target_resource_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "Administrative"
  }
}

module "xroad_deployment_dev" {
  source = "./modules/xroad_env"

  tags = local.tags
  envTags = {
    Environment = "development"
  }
  username = var.username
  organization = var.organization
  organization_dns_fragment = var.organization_dns_fragment
  location = var.location
  vm_username = var.vm_username
  ssh_pubkey = var.ssh_pubkey
  vm_password = var.vm_password
  firewall_whitelist = var.firewall_whitelist
  vm_sku = var.vm_sku
  ops_resource_group_name = azurerm_resource_group.ops.name
  rsv_name = azurerm_recovery_services_vault.rsv.name
  rsv_policy_id = azurerm_backup_policy_vm.xroad.id
  psql_password = var.psql_password
  xrd_webadmin_password = var.xrd_webadmin_password
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  actiongroup_id = azurerm_monitor_action_group.ag.id
  log_analytics_workspace_name = azurerm_log_analytics_workspace.law.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  vnetAddressPrefix = var.vnetDevAddressPrefix
  vmSubnetAddressPrefix = var.vmDevSubnetAddressPrefix
  psqlSubnetAddressPrefix = var.psqlDevSubnetAddressPrefix
  automatic_update_reboot_time = var.automatic_update_reboot_time

  env = "dev"
}

module "xroad_deployment_prd" {
  source = "./modules/xroad_env"

  tags = local.tags
  envTags = {
    Environment = "production"
  }
  username = var.username
  organization = var.organization
  organization_dns_fragment = var.organization_dns_fragment
  location = var.location
  vm_username = var.vm_username
  ssh_pubkey = var.ssh_pubkey
  vm_password = var.vm_password
  firewall_whitelist = var.firewall_whitelist
  vm_sku = var.vm_sku
  ops_resource_group_name = azurerm_resource_group.ops.name
  rsv_name = azurerm_recovery_services_vault.rsv.name
  rsv_policy_id = azurerm_backup_policy_vm.xroad.id
  psql_password = var.psql_password
  xrd_webadmin_password = var.xrd_webadmin_password
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  actiongroup_id = azurerm_monitor_action_group.ag.id
  log_analytics_workspace_name = azurerm_log_analytics_workspace.law.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  vnetAddressPrefix = var.vnetPrdAddressPrefix
  vmSubnetAddressPrefix = var.vmPrdSubnetAddressPrefix
  psqlSubnetAddressPrefix = var.psqlPrdSubnetAddressPrefix
  automatic_update_reboot_time = var.automatic_update_reboot_time

  env = "prd"
  count = var.deployment_type == "both" ? 1 : 0
}
