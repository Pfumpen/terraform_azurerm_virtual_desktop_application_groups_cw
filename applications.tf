resource "azurerm_virtual_desktop_application" "this" {
  for_each = var.type == "RemoteApp" ? var.remote_applications : {}

  name                         = each.value.name
  application_group_id         = azurerm_virtual_desktop_application_group.this.id
  friendly_name                = try(each.value.friendly_name, null)
  description                  = try(each.value.description, null)
  path                         = each.value.path
  command_line_argument_policy = each.value.command_line_argument_policy
  command_line_arguments       = try(each.value.command_line_arguments, null)
  show_in_portal               = try(each.value.show_in_portal, true)
  icon_path                    = try(each.value.icon_path, null)
  icon_index                   = try(each.value.icon_index, null)
}
