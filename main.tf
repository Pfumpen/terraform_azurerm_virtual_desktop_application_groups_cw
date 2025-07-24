locals {
  # Merge default tags with user-provided tags
  tags = merge(
    {
      "module" = "terraform-azurerm-virtual-desktop-application-group"
    },
    var.tags
  )
}

resource "azurerm_virtual_desktop_application_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  host_pool_id        = var.host_pool_id
  type                = var.type
  friendly_name       = var.friendly_name
  description         = var.description

  # This attribute is only applicable for 'Desktop' type application groups.
  # Using a conditional expression to set it to null for 'RemoteApp' type.
  default_desktop_display_name = var.type == "Desktop" ? var.default_desktop_display_name : null

  tags = local.tags
}
