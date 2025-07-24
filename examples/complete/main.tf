provider "azurerm" {
  features {}
  subscription_id = "f965ed2c-e6b3-4c40-8bea-ea3505a01aa2"
}

resource "azurerm_resource_group" "example" {
  name     = "rg-example-complete"
  location = "West Europe"
}

resource "azurerm_virtual_desktop_host_pool" "example" {
  name                = "hp-example-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  type                = "Pooled"
  load_balancer_type  = "BreadthFirst"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "la-example-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "virtual_desktop_application_group" {
  source = "../.."

  name                          = "vdag-complete-example"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  host_pool_id                  = azurerm_virtual_desktop_host_pool.example.id
  type                          = "RemoteApp"
  friendly_name                 = "Complete Example"
  description                   = "This is a complete example of a RemoteApp application group."
  remote_applications = {
    "notepad" = {
      name                        = "Notepad"
      path                        = "C:\\Windows\\System32\\notepad.exe"
      command_line_argument_policy = "Allow"
    },
    "mspaint" = {
      name                        = "Paint"
      path                        = "C:\\Windows\\System32\\mspaint.exe"
      command_line_argument_policy = "DoNotAllow"
      friendly_name               = "Microsoft Paint"
    }
  }
  role_assignments = {
    "Desktop Virtualization User" = {
      role_definition_id_or_name = "Desktop Virtualization User"
      principal_id               = "f8e33a27-934e-4438-a8a3-d758376f36a3" # This is a placeholder GUID
    }
  }
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    log_categories             = ["Checkpoint", "Error", "Management"]
    metric_categories          = ["AllMetrics"]
  }
  tags = {
    "environment" = "dev"
    "example"     = "complete"
  }
}
