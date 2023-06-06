resource "azurerm_virtual_network" "onpremise-nva-vnet" {
    name = "onpremise-nva-vnet"
    location = azurerm_resource_group.nvarg.location
    resource_group_name = azurerm_resource_group.nvarg.name
    address_space = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "internal" {
    name = "TrustedSubnet"
    resource_group_name = azurerm_resource_group.nvarg.name
    virtual_network_name = azurerm_virtual_network.onpremise-nva-vnet.name
    address_prefixes = ["10.1.100.0/24"]
}

resource "azurerm_subnet" "external" {
    name = "UntrustedSubnet"
    resource_group_name = azurerm_resource_group.nvarg.name
    virtual_network_name = azurerm_virtual_network.onpremise-nva-vnet.name
    address_prefixes = ["10.1.200.0/24"] 
}
