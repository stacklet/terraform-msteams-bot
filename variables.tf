# Required inputs from Stacklet
variable "wif_issuer_url" {
  description = "AWS outbound identity federation issuer URL"
  type        = string
  validation {
    condition     = can(regex("^https://", var.wif_issuer_url))
    error_message = "The wif_issuer_url must be a valid HTTPS URL."
  }
}

variable "trust_role_arn" {
  description = "AWS IAM role ARN that will generate WIF tokens"
  type        = string
  validation {
    condition     = can(regex("^arn:", var.trust_role_arn))
    error_message = "The trust_role_arn must be a valid ARN."
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
