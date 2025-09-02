#------------------------------------------------------------------------------
# General Variables
#------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "(Required) The name of the Virtual Desktop Application Group. Must adhere to Azure naming conventions."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$", var.name))
    error_message = "The name must be between 3 and 63 characters long, start and end with a letter or number, and can only contain letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the existing Resource Group where the resources will be deployed."

}

variable "location" {
  type        = string
  description = "(Required) The Azure region for the deployment."

}

variable "host_pool_id" {
  type        = string
  description = "(Required) The resource ID of the Virtual Desktop Host Pool to associate with this application group."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.DesktopVirtualization/hostPools/[^/]+$", var.host_pool_id))
    error_message = "The host_pool_id must be a valid Azure Resource ID for a Virtual Desktop Host Pool."
  }
}

variable "type" {
  type        = string
  description = "(Required) The type of application group. Must be either `RemoteApp` or `Desktop`."

  validation {
    condition     = contains(["RemoteApp", "Desktop"], var.type)
    error_message = "The type must be either 'RemoteApp' or 'Desktop'."
  }
}

variable "friendly_name" {
  type        = string
  description = "(Optional) A friendly name for the application group."
  default     = null
}

variable "description" {
  type        = string
  description = "(Optional) A description for the application group."
  default     = null
}

variable "default_desktop_display_name" {
  type        = string
  description = "(Optional) The display name for the default desktop. This is conditionally required if `type` is `Desktop` and portal access is needed."
  default     = null

  validation {
    condition     = var.type != "Desktop" || (var.type == "Desktop" && var.default_desktop_display_name != null)
    error_message = "The default_desktop_display_name is required when the application group type is 'Desktop'."
  }
}

#------------------------------------------------------------------------------
# Remote Applications
#------------------------------------------------------------------------------

variable "remote_applications" {
  type = map(object({
    name                         = string
    friendly_name                = optional(string)
    description                  = optional(string)
    path                         = string
    command_line_argument_policy = string
    command_line_arguments       = optional(string)
    show_in_portal               = optional(bool, true)
    icon_path                    = optional(string)
    icon_index                   = optional(number)
  }))
  description = "(Optional) A map of RemoteApp applications to create and associate with this group. This should only be used when `type` is `RemoteApp`."
  default     = {}

  validation {
    condition     = var.type != "RemoteApp" || (var.type == "RemoteApp" && length(var.remote_applications) > 0)
    error_message = "The remote_applications map cannot be empty when the application group type is 'RemoteApp'."
  }

  validation {
    condition = alltrue([
      for app in var.remote_applications : contains(["DoNotAllow", "Allow", "Require"], app.command_line_argument_policy)
    ])
    error_message = "The command_line_argument_policy for each remote application must be one of 'DoNotAllow', 'Allow', or 'Require'."
  }

  validation {
    condition = alltrue([
      for app in var.remote_applications : can(regex("^[a-zA-Z]:\\\\.*", app.path))
    ])
    error_message = "The path for each remote application must be a valid Windows path format (e.g., 'C:\\\\path\\\\to\\\\app.exe')."
  }
}

#------------------------------------------------------------------------------
# RBAC
#------------------------------------------------------------------------------

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    condition                  = optional(string)
    condition_version          = optional(string)
  }))
  description = "(Optional) A map of role assignments to create on the application group."
  default     = {}

  validation {
    condition = alltrue([
      for assignment in var.role_assignments : assignment.role_definition_id_or_name != null
    ])
    error_message = "The role_definition_id_or_name is required for each role assignment."
  }
}

#------------------------------------------------------------------------------
# Diagnostic Settings
#------------------------------------------------------------------------------

variable "diagnostics_level" {
  description = "Defines the desired diagnostic intent. 'all' and 'audit' are dynamically mapped to available categories. Possible values: 'none', 'all', 'audit', 'custom'."
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "all", "audit", "custom"], var.diagnostics_level)
    error_message = "Valid values for diagnostics_level are 'none', 'all', 'audit', or 'custom'."
  }
}

variable "diagnostic_settings" {
  description = "A map containing the destination IDs for diagnostic settings. When diagnostics are enabled, exactly one destination must be specified."
  type = object({
    log_analytics_workspace_id     = optional(string)
    eventhub_authorization_rule_id = optional(string)
    storage_account_id             = optional(string)
  })
  default = {}

  validation {
    condition = var.diagnostics_level == "none" || (
      (try(var.diagnostic_settings.log_analytics_workspace_id, null) != null ? 1 : 0) +
      (try(var.diagnostic_settings.eventhub_authorization_rule_id, null) != null ? 1 : 0) +
      (try(var.diagnostic_settings.storage_account_id, null) != null ? 1 : 0) == 1
    )
    error_message = "When 'diagnostics_level' is not 'none', exactly one of 'log_analytics_workspace_id', 'eventhub_authorization_rule_id', or 'storage_account_id' must be specified in the 'diagnostic_settings' object."
  }
}

variable "diagnostics_custom_logs" {
  description = "A list of specific log categories to enable when diagnostics_level is 'custom'."
  type        = list(string)
  default     = []
}

variable "diagnostics_custom_metrics" {
  description = "A list of specific metric categories to enable. Use ['AllMetrics'] for all."
  type        = list(string)
  default     = ["AllMetrics"]
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "(Optional) A map of tags to assign to the resources."
  default     = {}
}
