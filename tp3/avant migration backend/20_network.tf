
resource "azurerm_virtual_network" "atelier3" {
  name                = "network-atelier3"
  address_space       = ["10.10.0.0/16"]
  location            = data.azurerm_resource_group.rg_atelier3.location
  resource_group_name = data.azurerm_resource_group.rg_atelier3.name
  tags = {
    user = data.azurerm_resource_group.rg_atelier3.tags["user"]
  }
}
resource "azurerm_subnet" "atelier3" {
  name                 = "atelier3-subnet"
  resource_group_name  = data.azurerm_resource_group.rg_atelier3.name
  virtual_network_name = azurerm_virtual_network.atelier3.name
  address_prefixes     = ["10.10.1.0/24"]
}

#### PHASE 3
resource "azurerm_virtual_network" "vnet" {
  for_each = local.modified_virtual_networks

  name                = each.key
  location            = each.value.location
  resource_group_name = data.azurerm_resource_group.rg_atelier3.name
  address_space       = each.value.address_space

  tags = {
    user              = data.azurerm_resource_group.rg_atelier3.tags["user"]
    environment       = each.value.environment
    addr_space_number = each.value.addr_space_number
  }
}



resource "azurerm_subnet" "subnets" {
  for_each = local.subnets

  name                = each.value.subnet_name
  resource_group_name = data.azurerm_resource_group.rg_atelier3.name
  #virtual_network_name = each.value.vnet_name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.address_prefix]
}
