provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-demo-01" {
  name     = "rg-demo-01"
  location = "uksouth"
}

resource "azurerm_virtual_network" "vnet-demo" {
  name                = "vnet-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-demo-01.location
  resource_group_name = azurerm_resource_group.rg-demo-01.name
}

resource "azurerm_subnet" "subnet-demo" {
  name                 = "subnet-demo"
  resource_group_name  = azurerm_resource_group.rg-demo-01.name
  virtual_network_name = azurerm_virtual_network.vnet-demo.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic-demo" {
  name                = "nic-demo"
  location            = azurerm_resource_group.rg-demo-01.location
  resource_group_name = azurerm_resource_group.rg-demo-01.name

  ip_configuration {
    name                          = "ipconfig-demo"
    subnet_id                     = azurerm_subnet.subnet-demo.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm-demo" {
  name                  = "vm-demo"
  location              = azurerm_resource_group.rg-demo-01.location
  resource_group_name   = azurerm_resource_group.rg-demo-01.name
  network_interface_ids = [azurerm_network_interface.nic-demo.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "osdisk-demo"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vm-demo"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}