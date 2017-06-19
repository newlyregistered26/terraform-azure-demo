variable "resource_group_name" {}
variable "security_group_id" {}
variable "location" {}
variable "prefix" {}
variable "subnet_id" {}
variable "availability_set_id" {}
variable "vhd_uri" {}

resource "azurerm_public_ip" "master" {
  name = "${var.prefix}-ip"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "master" {
  name = "${var.prefix}-interface"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  network_security_group_id = "${var.security_group_id}"
  internal_dns_name_label = "${var.prefix}"

  ip_configuration {
    name = "${var.prefix}-ipconfig"
    subnet_id = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.master.id}"
  }
}

resource "azurerm_virtual_machine" "master" {
  name = "${var.prefix}"

  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.master.id}"]
  vm_size = "Standard_D2"
  availability_set_id = "${var.availability_set_id}"
    tags {
    costcode= "3456"
		Owner = "BAU"
    Creator = "ARitchie"
    Environment ="dev"
            }
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
	    publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2012-R2-Datacenter"
        version = "latest"
          }

  storage_os_disk {
    name = "${var.prefix}"
    vhd_uri = "${var.vhd_uri}"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "somename"
    admin_username = "tfadmin"
    admin_password = "Blah1234!Blah1234!"
  }
   os_profile_windows_config {
 /*
 Windows defaults the following to true, so if you change other properties 
 like tags, it causes total image recreation, so best set them to false initially 
 */
    enable_automatic_upgrades = "false"
		provision_vm_agent= "false"}
}

output "network_interface_id" {
  value = "${azurerm_network_interface.master.id}"
}

output "ip_address" {
  value = "${azurerm_public_ip.master.ip_address}"
}