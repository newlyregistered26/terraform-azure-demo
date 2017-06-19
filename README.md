# terraform-azure-demo
This is a project for demonstrating Terraform with AzureRM
This will provision a virtual network, security group, route table, availability set, storage container etc to support a single VM within Azure RM.
It also demonstrates the use of a module. 
## Instructions
### Environment Variables
You will require AzureRM credentials - it is recommended to use system variables for the following. 
ARM_CLIENT_ID=
ARM_CLIENT_SECRET=
ARM_SUBSCRIPTION_ID=
ARM_TENANT_ID=

Directions on creating these credentials provided here 
https://www.terraform.io/docs/providers/azurerm/


Else populate the following values within main.tf
client_id = ""
client_secret = ""
tenant_id = ""
subscription_id = ""