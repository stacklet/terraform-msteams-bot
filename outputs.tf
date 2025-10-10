# Azure AD context information
output "tenant_id" {
  description = "Azure AD tenant ID"
  value       = data.azuread_client_config.current.tenant_id
}

output "client_id" {
  description = "Teams bot application/client ID"
  value       = azuread_application.teams_bot.client_id
}

output "roundtrip_digest" {
  description = "Roundtrip digest for configuration validation"
  value       = var.roundtrip_digest
}

# Base64-encoded JSON blob for Stacklet platform
output "access_blob" {
  description = "Configuration for Stacklet platform - copy this value to Stacklet Teams configuration"
  value = base64encode(jsonencode({
    tenantId        = data.azuread_client_config.current.tenant_id
    clientId        = azuread_application.teams_bot.client_id
    roundtripDigest = var.roundtrip_digest
  }))
  sensitive = false
}