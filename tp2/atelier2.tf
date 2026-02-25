### Configuration de terraform
terraform {
  # Définir la version minimale requise de Terraform
  required_version = ">= 1.9.0"
  # Déclaration des providers requis
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.3" # Version 4.3 minimum, sans montées majeures
    }
    ##### BONUS1 #####
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
  # Configuration du backend local pour stocker l'état
  backend "local" {
    path = "atelier2.tfstate"
  }
}
# Configuration du provider AzureRM
provider "azurerm" {
  features {} # Toutes les fonctionnalités par défaut
  use_cli         = true
  subscription_id = "ca5c57dd-3aab-4628-a78c-978830d03bbd" # ID récupéré depuis le portail Azure
}


### Data et Variable ###

# Mise en data du ressource groupe à utilisé !
# il est récupérable via l'interface azure ou 
# az group list --output table
data "azurerm_resource_group" "rg_atelier2" {
  name = "rg-fthouin_cours-terraform"
}
# Mise en Data de l'ip public de l'ENI
data "http" "ippubeni" {
  url = "https://ifconfig.me/ip"
}

### Declaration des variable ###
variable "vmname" {
  type    = string
  default = "vm-terraform-atelier2"
}


### déclaration des ressources ###
resource "azurerm_virtual_network" "atelier2" {
  name                = "network-atelier2"
  address_space       = ["10.10.0.0/16"]
  location            = data.azurerm_resource_group.rg_atelier2.location
  resource_group_name = data.azurerm_resource_group.rg_atelier2.name
  tags = {
    user = data.azurerm_resource_group.rg_atelier2.tags["user"]
  }
}



resource "azurerm_subnet" "atelier2" {
  name                 = "atelier2-subnet"
  resource_group_name  = data.azurerm_resource_group.rg_atelier2.name
  virtual_network_name = azurerm_virtual_network.atelier2.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_interface" "atelier2" {
  name                = "atelier2-nic"
  location            = data.azurerm_resource_group.rg_atelier2.location
  resource_group_name = data.azurerm_resource_group.rg_atelier2.name
  tags = {
    user = data.azurerm_resource_group.rg_atelier2.tags["user"]
  }
  ip_configuration {
    name                          = "atelier2-terraform"
    subnet_id                     = azurerm_subnet.atelier2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.atelier2.id
  }
}




resource "azurerm_linux_virtual_machine" "atelier2" {
  name                = var.vmname
  resource_group_name = data.azurerm_resource_group.rg_atelier2.name
  location            = data.azurerm_resource_group.rg_atelier2.location
  size                = "Standard_B1ls"
  admin_username      = "penthium"
  tags = {
    user = data.azurerm_resource_group.rg_atelier2.tags["user"]
  }
  network_interface_ids = [
    azurerm_network_interface.atelier2.id,
  ]
  disable_password_authentication = true
  admin_ssh_key {
    username   = "penthium"
    public_key = file("~/.ssh/id_ed25519.pub") # Il faut penser a générer ses clef avant
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }
  source_image_reference {
    publisher = "Canonical"
    sku       = "server"
    offer     = "ubuntu-24_04-lts"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "atelier2" {
  name                = "atelier2-pip"
  location            = data.azurerm_resource_group.rg_atelier2.location
  resource_group_name = data.azurerm_resource_group.rg_atelier2.name
  allocation_method   = "Static"
  tags = {
    user = data.azurerm_resource_group.rg_atelier2.tags["user"]
  }
  domain_name_label = "${var.vmname}-${random_string.bonus1.result}"
}

resource "azurerm_network_security_group" "atelier2" {
  name                = "atelier2-nsg"
  location            = data.azurerm_resource_group.rg_atelier2.location
  resource_group_name = data.azurerm_resource_group.rg_atelier2.name
  tags = {
    user = data.azurerm_resource_group.rg_atelier2.tags["user"]
  }
  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = data.http.ippubeni.response_body
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.atelier2.id
  network_security_group_id = azurerm_network_security_group.atelier2.id
}


##### BONUS1 #####
resource "random_string" "bonus1" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}



### Déclaration des output ###

output "rg-location" {
  value = data.azurerm_resource_group.rg_atelier2.location
}

output "rg-tags" {
  value = data.azurerm_resource_group.rg_atelier2.tags
}
output "ssh_command" {
  value = "Pour tester la bonne création de votre vm faire : ${azurerm_linux_virtual_machine.atelier2.admin_username}@${azurerm_public_ip.atelier2.fqdn}"
}

output "ipprivateconfiguration" {
  value = azurerm_network_interface.atelier2.private_ip_address
}
