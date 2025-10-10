# Required inputs from Stacklet
variable "oidc_issuer" {
  description = "OIDC issuer URL"
  type        = string
  validation {
    condition     = can(regex("^https://", var.oidc_issuer))
    error_message = "The oidc_issuer must be a valid HTTPS URL."
  }
}

variable "oidc_client" {
  description = "OIDC client ID"
  type        = string
  validation {
    condition     = length(var.oidc_client) > 0
    error_message = "The oidc_client must not be empty."
  }
}

variable "bot_endpoint" {
  description = "Bot webhook endpoint URL"
  type        = string
  validation {
    condition     = can(regex("^https://", var.bot_endpoint))
    error_message = "The bot_endpoint must be a valid HTTPS URL."
  }
}

# Required customer inputs
variable "prefix" {
  description = "Prefix for all resource names (keep short to allow room for customer prefixes)"
  type        = string
  validation {
    condition     = length(var.prefix) > 0 && length(var.prefix) <= 32
    error_message = "The prefix must be between 1 and 32 characters long."
  }
}


variable "roundtrip_digest" {
  type        = string
  description = "Token used by the Stacklet Platform to detect mismatch between customerConfig and accessConfig."
}

variable "tags" {
  description = "Tags to apply to all Azure resources"
  type        = map(string)
  default     = {}
}
