resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-xroad-${var.env}"
  location            = var.location
  address_space       = [var.vnetAddressPrefix]
  resource_group_name = azurerm_resource_group.xroad.name

  tags = merge(var.tags, var.envTags)
}

resource "azurerm_subnet" "snet-xroadvm" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = "snet-xroadvm"
  resource_group_name  = azurerm_resource_group.xroad.name
  address_prefixes     = [var.vmSubnetAddressPrefix]
}

resource "azurerm_subnet" "snet-psql" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = "snet-psql"
  resource_group_name  = azurerm_resource_group.xroad.name
  address_prefixes     = [var.psqlSubnetAddressPrefix]
  
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }

  service_endpoints = [
    "Microsoft.Storage"
  ]
}

resource "azurerm_private_dns_zone" "xroad-psql" {
  name                = "psql-${var.organization_dns_fragment}-xroad-${var.env}.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.xroad.name

  tags = merge(var.tags, var.envTags)
}

resource "azurerm_private_dns_zone_virtual_network_link" "pdns-vnet-link" {
  name                  = "psql-${var.organization_dns_fragment}-xroad-${var.env}.private.postgres.database.azure.com"
  private_dns_zone_name = azurerm_private_dns_zone.xroad-psql.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.xroad.name
}

resource "azurerm_network_security_group" "xroad_servers" {
  name                = "nsg-xroad-securityserver-${var.env}"
  location            = var.location
  resource_group_name = azurerm_resource_group.xroad.name

  security_rule {
    access                       = "Allow"
    direction                    = "Inbound"
    name                         = "SSH"
    priority                     = 300
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_address_prefixes        = var.firewall_whitelist
    destination_port_range       = "22"
    destination_address_prefix   = "*"
    description                  = ""
    destination_address_prefixes = []
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "AllowXRoadInternal"
    priority                   = 340
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefixes      = var.firewall_whitelist
    destination_port_ranges    = ["80", "443", "4000"]
    destination_address_prefix = "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "AllowXRoadExternalInbound"
    priority                   = 350
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_ranges    = ["5500", "5577"]
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, var.envTags)
}

resource "azurerm_subnet_network_security_group_association" "xroad_servers" {
  subnet_id                 = azurerm_subnet.snet-xroadvm.id
  network_security_group_id = azurerm_network_security_group.xroad_servers.id
}
