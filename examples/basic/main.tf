provider "azurerm" {
  features {}
  subscription_id = "f965ed2c-e6b3-4c40-8bea-ea3505a01aa2"
}

resource "azurerm_resource_group" "example" {
  name     = "rg-example-basic"
  location = "West Europe"
}

resource "azurerm_virtual_desktop_host_pool" "example" {
  name                = "hp-example-basic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  type                = "Pooled"
  load_balancer_type  = "BreadthFirst"
}

module "virtual_desktop_application_group" {
  source = "../.."

  name                          = "vdag-basic-example"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  host_pool_id                  = azurerm_virtual_desktop_host_pool.example.id
  type                          = "Desktop"
  default_desktop_display_name  = "Basic Desktop"
}
