variable "username" {
  type = string
  description = "Username of the person executing the deployment. Used for tagging of resources."
}

variable "organization" {
  type = string
  description = "Full name of organization/department/project. Used for certificate 'O' values. Example: Well Advised ehf"
}

variable "organization_dns_fragment" {
  type = string
  description = "String used in dns records for the azure resources. Required to conform with dns label naming rules. Example: watf"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$", var.organization_dns_fragment))
    error_message = "The DNS segment must start and end with a letter or digit, be 1 to 63 characters long, and can contain hyphens but not start or end with them."
  }
}

variable "deployment_type" {
  type        = string
  description = "Deploy only development or both dev and prd? Valid values are 'dev' or 'both'."

  validation {
    condition     = var.deployment_type == "dev" || var.deployment_type == "both"
    error_message = "The deployment_type must be 'dev' or 'both'."
  }
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "psql_password" {
  type = string
}

variable "vnetDevAddressPrefix" {
  type    = string
  default = "10.83.140.0/23"
}
variable "vnetPrdAddressPrefix" {
  type    = string
  default = "10.83.142.0/23"
}

variable "vmDevSubnetAddressPrefix" {
  type    = string
  default = "10.83.140.0/24"
}
variable "vmPrdSubnetAddressPrefix" {
  type    = string
  default = "10.83.142.0/24"
}

variable "psqlDevSubnetAddressPrefix" {
  type    = string
  default = "10.83.141.0/24"
}
variable "psqlPrdSubnetAddressPrefix" {
  type    = string
  default = "10.83.143.0/24"
}

variable "xrd_webadmin_password" {
  type = string
  description = "Password for the xroad web administration user. Username xrd."
}

variable "vm_username" {
  type = string
}

variable "ssh_pubkey" {
  type        = string
  description = "preferred linux authentication method, overrides password authentication"
  default     = null
}

variable "vm_password" {
  type        = string
  description = "alternative to ssh pubkey authentication"
  default     = null
}

variable "firewall_whitelist" {
  type        = set(string)
  description = "Comma-separated values of network address blocks that can communicate with administrative ports of the xroad securityserver. Example: [\"178.19.55.120/29\",\"153.92.133.223\"]"
}

variable "vm_sku" {
  type    = string
  default = "Standard_B2als_v2"
}

variable "actiongroup_email" {
  type = string
  description = "Email address to send alerts to"
}

variable "automatic_update_reboot_time" {
  type = string
  default = "04:00"
  description = "In the edge case of a security update requiring reboot (kernel udpates), at what time to allow?"
}
