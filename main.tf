# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to local file
resource "local_file" "ssh_private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/ssh_keys/ollama_vm_key"
  file_permission = "0600"
}

# Save public key to local file  
resource "local_file" "ssh_public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/ssh_keys/ollama_vm_key.pub"
  file_permission = "0644"
}

# Create a resource group
resource "azurerm_resource_group" "ollama_rg" {
  name     = "rg-ollama-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "Ollama"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "ollama_vnet" {
  name                = "vnet-ollama-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ollama_rg.location
  resource_group_name = azurerm_resource_group.ollama_rg.name

  tags = {
    Environment = var.environment
    Project     = "Ollama"
  }
}

# Create a subnet
resource "azurerm_subnet" "ollama_subnet" {
  name                 = "subnet-ollama-${var.environment}"
  resource_group_name  = azurerm_resource_group.ollama_rg.name
  virtual_network_name = azurerm_virtual_network.ollama_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP
resource "azurerm_public_ip" "ollama_public_ip" {
  name                = "pip-ollama-${var.environment}"
  location            = azurerm_resource_group.ollama_rg.location
  resource_group_name = azurerm_resource_group.ollama_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project     = "Ollama"
  }
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "ollama_nsg" {
  name                = "nsg-ollama-${var.environment}"
  location            = azurerm_resource_group.ollama_rg.location
  resource_group_name = azurerm_resource_group.ollama_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Ollama_API"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "11434"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Project     = "Ollama"
  }
}

# Create network interface
resource "azurerm_network_interface" "ollama_nic" {
  name                = "nic-ollama-${var.environment}"
  location            = azurerm_resource_group.ollama_rg.location
  resource_group_name = azurerm_resource_group.ollama_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ollama_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ollama_public_ip.id
  }

  tags = {
    Environment = var.environment
    Project     = "Ollama"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "ollama_nsg_association" {
  network_interface_id      = azurerm_network_interface.ollama_nic.id
  network_security_group_id = azurerm_network_security_group.ollama_nsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "ollama_storage" {
  name                     = "st${random_string.storage_suffix.result}"
  location                 = azurerm_resource_group.ollama_rg.location
  resource_group_name      = azurerm_resource_group.ollama_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Project     = "Ollama"
  }
}

# Generate random string for storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "ollama_vm" {
  name                = "vm-ollama-${var.environment}"
  location            = azurerm_resource_group.ollama_rg.location
  resource_group_name = azurerm_resource_group.ollama_rg.name
  size                = var.vm_size
  admin_username      = "azureuser"

  # Disable password authentication
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.ollama_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/cloud-init.yaml"))

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.ollama_storage.primary_blob_endpoint
  }

  tags = {
    Environment = var.environment
    Project     = "Ollama"
  }
}
