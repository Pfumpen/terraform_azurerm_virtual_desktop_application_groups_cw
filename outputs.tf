output "id" {
  description = "The resource ID of the Virtual Desktop Application Group."
  value       = azurerm_virtual_desktop_application_group.this.id
}

output "name" {
  description = "The name of the Virtual Desktop Application Group."
  value       = azurerm_virtual_desktop_application_group.this.name
}

output "remote_applications" {
  description = "A map of the created `azurerm_virtual_desktop_application` resources, with their IDs and names."
  value = {
    for k, v in azurerm_virtual_desktop_application.this : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "role_assignment_ids" {
  description = "A map of the created `azurerm_role_assignment` resource IDs."
  value = {
    for k, v in azurerm_role_assignment.this : k => v.id
  }
  sensitive = true
}
