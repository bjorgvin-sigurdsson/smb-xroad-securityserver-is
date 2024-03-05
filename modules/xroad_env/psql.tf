# xroad installation scripts create databases and users

resource "azurerm_postgresql_flexible_server" "psql" {
  name                   = "psql-${var.organization_dns_fragment}-xroad-${var.env}"
  resource_group_name    = azurerm_resource_group.xroad.name
  location               = var.location
  version                = "15"
  administrator_login    = "postgres"
  administrator_password = var.psql_password

  storage_mb                   = 32768
  sku_name                     = "B_Standard_B1ms"
  backup_retention_days        = 30
  geo_redundant_backup_enabled = var.env == "prd" ? true : false
  auto_grow_enabled            = true

  # Is in fact required for redeployments
  zone = 1

  delegated_subnet_id = azurerm_subnet.snet-psql.id
  private_dns_zone_id = azurerm_private_dns_zone.xroad-psql.id

  tags = merge(var.tags, var.envTags)

  depends_on = [azurerm_private_dns_zone_virtual_network_link.pdns-vnet-link]
}

# We must allowlist the HSTORE datatype before xroad setup
resource "azurerm_postgresql_flexible_server_configuration" "hstore" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.psql.id
  value     = "HSTORE"
}
