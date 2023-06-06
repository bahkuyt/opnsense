resource "azurerm_public_ip" "nva-vm-pip" {
  name                = "nva-pip01"
  location            = azurerm_resource_group.nvarg.location
  resource_group_name = azurerm_resource_group.nvarg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "internal" {
  name                = "nva-ni01"
  location            = azurerm_resource_group.nvarg.location
  resource_group_name = azurerm_resource_group.nvarg.name

  ip_configuration {
    name                          = "ipConfig1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "external" {
  name                = "nva-ni02"
  location            = azurerm_resource_group.nvarg.location
  resource_group_name = azurerm_resource_group.nvarg.name

  ip_configuration {
    name                          = "ipConfig2"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.nva-vm-pip.id
  }
}

resource "azurerm_network_security_group" "nva_nsg" {
  name                = "nva-nsg"
  location            = azurerm_resource_group.nvarg.location
  resource_group_name = azurerm_resource_group.nvarg.name

  security_rule {
    name                       = "In-Any"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Out-Any"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  
}

resource "azurerm_network_interface_security_group_association" "internal" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.nva_nsg.id
}

resource "azurerm_network_interface_security_group_association" "external" {
  network_interface_id      = azurerm_network_interface.external.id
  network_security_group_id = azurerm_network_security_group.nva_nsg.id
}

resource "azurerm_linux_virtual_machine" "nvavm" {
  name                = "opnsense"
  resource_group_name = azurerm_resource_group.nvarg.name
  location            = azurerm_resource_group.nvarg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd!1234&Azure"
  network_interface_ids = [
    azurerm_network_interface.internal.id,
    azurerm_network_interface.external.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "thefreebsdfoundation"
    offer     = "freebsd-13_1"
    sku       = "13_1-release"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "example" {
  name                 = "opnsense bootsrap installation"
  virtual_machine_id   = azurerm_linux_virtual_machine.nvavm.id
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.5"
  auto_upgrade_minor_version = false

  settings = <<SETTINGS
 {
  "fileUris": "https://raw.githubusercontent.com/bahkuyt/opnsense/main/opnsense%20bootstrap/configureopnsense.sh"
  "commandToExecute": "sh configureopnsense.sh"
 }
SETTINGS


  tags = {
    environment = "Production"
  }
}