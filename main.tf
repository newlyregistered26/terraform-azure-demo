variable "prefix" { default = "azuredemo" }
variable "location" { default = "Australia East" }
variable "azure_storage_name" { default = "tfsomethinguniquea12345" }
provider "azurerm" {
/* These have been provided as environment variables so this section has been commented out
client_id = ""
client_secret = ""
tenant_id = ""
subscription_id = ""
*/}

resource "azurerm_resource_group" "default" {
  name     = "${var.prefix}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "default" {
  name = "${var.prefix}-net"
  address_space = ["10.0.0.0/16"]
  location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.default.name}"
}

resource "azurerm_network_security_group" "default" {
  name = "${var.prefix}-security-group"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
   security_rule {
        name = "default-allow-rdp"
        priority = 1000
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "3389"
        source_address_prefix = "0.0.0.0/0"
        destination_address_prefix = "*"
    }
    security_rule {
        name = "winrm"
        priority = 1010
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "5985"
        source_address_prefix = "0.0.0.0/0"
        destination_address_prefix = "*"
    }
    security_rule {
        name = "winrm-out"
        priority = 100
        direction = "Outbound"
        access = "Allow"
        protocol = "*"
        source_port_range = "*"
        destination_port_range = "5985"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

}


resource "azurerm_route_table" "default" {
  name = "${var.prefix}-route-table"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"

  route {
    name = "local"
    address_prefix = "10.0.0.0/16"
    next_hop_type = "vnetlocal"
  }

  route {
    name = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = "internet"
  }
}

resource "azurerm_subnet" "default" {
  name = "${var.prefix}-subnet"
  resource_group_name = "${azurerm_resource_group.default.name}"
  virtual_network_name = "${azurerm_virtual_network.default.name}"
  address_prefix = "10.0.1.0/24"
  route_table_id = "${azurerm_route_table.default.id}"
}



resource "azurerm_storage_account" "default" {
  name = "${var.azure_storage_name}"
  resource_group_name = "${azurerm_resource_group.default.name}"

  location = "${var.location}"
  account_kind = "Storage"
  account_type = "Standard_GRS"
  enable_blob_encryption = true
}

resource "azurerm_storage_container" "images" {
  name = "vhds"
  resource_group_name = "${azurerm_resource_group.default.name}"
  storage_account_name = "${azurerm_storage_account.default.name}"
  container_access_type = "private"
}

resource "azurerm_availability_set" "default" {
  name = "${var.prefix}-availability-set"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
}

module "master1_virtual_machine" {
  source = "./virtual_machine"
  prefix = "${var.prefix}-master1"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  subnet_id = "${azurerm_subnet.default.id}"
  security_group_id = "${azurerm_network_security_group.default.id}"
  vhd_uri = "${azurerm_storage_account.default.primary_blob_endpoint}${azurerm_storage_container.images.name}/master1.vhd"
  availability_set_id = "${azurerm_availability_set.default.id}"

}
output "master1_ip_address" {
  value = "${module.master1_virtual_machine.ip_address}"
}