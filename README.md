# Terraform Azure RM Virtual Desktop Application Group Module

## Description

This Terraform module creates and manages an Azure Virtual Desktop Application Group, including its associated applications, role assignments, and diagnostic settings. It supports both `RemoteApp` and `Desktop` application group types.

## Features

- Creates Virtual Desktop Application Groups of type `RemoteApp` or `Desktop`.
- For `RemoteApp` groups, creates and associates a collection of `virtual_desktop_application` resources from a complex variable.
- For `Desktop` groups, configures the default desktop display name.
- Implements standardized Role-Based Access Control (RBAC) using a `role_assignments` map variable to assign roles on the application group scope.
- Implements standardized Diagnostic Settings to send logs and metrics to a pre-existing Log Analytics Workspace, Event Hub, or Storage Account.
- Supports descriptive friendly names and descriptions.
- Standardized tagging for all created resources.

## Usage

### Basic Example (Desktop Application Group)

```hcl
module "virtual_desktop_application_group" {
  source = "./"

  name                = "my-app-group"
  resource_group_name = "my-rg"
  location            = "West Europe"
  host_pool_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.DesktopVirtualization/hostPools/my-hp"
  type                = "Desktop"
  default_desktop_display_name = "My Desktop"
}
```

### Complete Example (RemoteApp Application Group)

```hcl
module "virtual_desktop_application_group" {
  source = "./"

  name                = "my-remote-app-group"
  resource_group_name = "my-rg"
  location            = "West Europe"
  host_pool_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.DesktopVirtualization/hostPools/my-hp"
  type                = "RemoteApp"
  friendly_name       = "My RemoteApp Group"
  description         = "A group for my remote applications."

  remote_applications = {
    "notepad" = {
      name                        = "Notepad"
      path                        = "C:\\Windows\\System32\\notepad.exe"
      command_line_argument_policy = "Allow"
    }
    "calc" = {
      name                        = "Calculator"
      path                        = "C:\\Windows\\System32\\calc.exe"
      command_line_argument_policy = "DoNotAllow"
    }
  }

  role_assignments = {
    "Desktop Virtualization User" = {
      role_definition_id_or_name = "Desktop Virtualization User"
      principal_id               = "00000000-0000-0000-0000-000000000000"
    }
  }

  diagnostics_level = "detailed"
  diagnostic_settings = {
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.OperationalInsights/workspaces/my-la"
  }

  tags = {
    "environment" = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Virtual Desktop Application Group. Must adhere to Azure naming conventions. | `string` | n/a | yes |
| `resource_group_name` | The name of the existing Resource Group where the resources will be deployed. | `string` | n/a | yes |
| `location` | The Azure region for the deployment. | `string` | n/a | yes |
| `host_pool_id` | The resource ID of the Virtual Desktop Host Pool to associate with this application group. | `string` | n/a | yes |
| `type` | The type of application group. Must be either `RemoteApp` or `Desktop`. | `string` | n/a | yes |
| `friendly_name` | A friendly name for the application group. | `string` | `null` | no |
| `description` | A description for the application group. | `string` | `null` | no |
| `default_desktop_display_name` | The display name for the default desktop. This is conditionally required if `type` is `Desktop` and portal access is needed. | `string` | `null` | no |
| `remote_applications` | A map of RemoteApp applications to create and associate with this group. This should only be used when `type` is `RemoteApp`. | `map(object)` | `{}` | no |
| `role_assignments` | A map of role assignments to create on the application group. | `map(object)` | `{}` | no |
| `diagnostics_level` | Defines the detail level for diagnostics. Possible values: 'none', 'basic', 'detailed', 'custom'. | `string` | `"basic"` | no |
| `diagnostic_settings` | A map containing the destination IDs for diagnostic settings. When diagnostics are enabled, exactly one destination must be specified. | `object` | `{}` | no |
| `diagnostics_custom_logs` | A list of log categories to enable when diagnostics_level is 'custom'. | `list(string)` | `[]` | no |
| `diagnostics_custom_metrics` | A list of metric categories to enable when diagnostics_level is 'custom'. Use ['AllMetrics'] for all. | `list(string)` | `[]` | no |
| `tags` | A map of tags to assign to the resources. | `map(string)` | `{}` | no |

### `remote_applications`

The `remote_applications` variable is a map of objects, where each object represents a RemoteApp application. The following attributes are available:

- `name` (string, Required): The name of the application resource.
- `friendly_name` (string, Optional): The friendly name for the application.
- `description` (string, Optional): A description for the application.
- `path` (string, Required): The file path of the application on the session host VM.
- `command_line_argument_policy` (string, Required): Policy for command line arguments. Must be one of `DoNotAllow`, `Allow`, `Require`.
- `command_line_arguments` (string, Optional): Command line arguments to use with the application.
- `show_in_portal` (bool, Optional): Whether to show the application in the RD Web Access portal. Defaults to `true`.
- `icon_path` (string, Optional): The path to the application's icon file.
- `icon_index` (number, Optional): The index of the icon in the icon file.

#### Type Definition

```hcl
variable "remote_applications" {
  type = map(object({
    name                        = string
    friendly_name               = optional(string)
    description                 = optional(string)
    path                        = string
    command_line_argument_policy = string
    command_line_arguments      = optional(string)
    show_in_portal              = optional(bool, true)
    icon_path                   = optional(string)
    icon_index                  = optional(number)
  }))
}
```

#### Usage Example

```hcl
remote_applications = {
  "notepad" = {
    name                        = "Notepad"
    path                        = "C:\\Windows\\System32\\notepad.exe"
    command_line_argument_policy = "Allow"
  }
}
```

### `role_assignments`

The `role_assignments` variable is a map of objects, where each object represents a role assignment. The following attributes are available:

- `role_definition_id_or_name` (string, Required): The role definition name or ID.
- `principal_id` (string, Required): The object ID of the principal (user, group, service principal).
- `principal_type` (string, Optional): The type of the principal.
- `condition` (string, Optional): An ABAC condition.
- `condition_version` (string, Optional): The version of the ABAC condition.

#### Type Definition

```hcl
variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    condition                  = optional(string)
    condition_version          = optional(string)
  }))
}
```

#### Usage Example

```hcl
role_assignments = {
  "Desktop Virtualization User" = {
    role_definition_id_or_name = "Desktop Virtualization User"
    principal_id               = "00000000-0000-0000-0000-000000000000"
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| `id` | The resource ID of the Virtual Desktop Application Group. |
| `name` | The name of the Virtual Desktop Application Group. |
| `remote_applications` | A map of the created `azurerm_virtual_desktop_application` resources, with their IDs and names. |
| `role_assignment_ids` | A map of the created `azurerm_role_assignment` resource IDs. |

## License

This module is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
