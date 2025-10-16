# Current Azure AD and subscription context
data "azuread_client_config" "current" {}

# Microsoft Graph service principal (exists in every tenant)
data "azuread_service_principal" "msgraph" {
  display_name = "Microsoft Graph"
}

locals {
  # Microsoft Graph permissions required for Teams bot functionality
  msgraph_permissions = toset([
    "User.Read.All",                                 # Read users to map from emails to identities
    "TeamsAppInstallation.ReadWriteSelfForTeam.All", # Install/uninstall app for teams
    "TeamsAppInstallation.ReadWriteSelfForUser.All", # Install/uninstall app for users.
    "Team.ReadBasic.All",                            # Read teams to allow mapping configuration
    "Channel.ReadBasic.All",                         # Read teams to allow mapping configuration
    "AppCatalog.Read.All",                           # To discover uploaded Teams app identity
  ])
}

# Random string for unique bot service name
resource "random_string" "bot_suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# Resource group for Azure resources
resource "azurerm_resource_group" "teams_bot" {
  name     = "${var.prefix}-teams-bot"
  location = "East US"
  tags     = var.tags
}

# Azure AD App Registration for the bot
resource "azuread_application" "teams_bot" {
  display_name = "Stacklet Teams Bot"
  owners       = [data.azuread_client_config.current.object_id]

  # Required Bot Framework permissions
  required_resource_access {
    resource_app_id = data.azuread_service_principal.msgraph.client_id

    dynamic "resource_access" {
      for_each = local.msgraph_permissions
      content {
        id   = data.azuread_service_principal.msgraph.app_role_ids[resource_access.key]
        type = "Role"
      }
    }
  }
}

# Service Principal for the app
resource "azuread_service_principal" "teams_bot" {
  client_id = azuread_application.teams_bot.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Federated Identity Credential - trusts OIDC provider
resource "azuread_application_federated_identity_credential" "oidc_provider" {
  application_id = azuread_application.teams_bot.id
  display_name   = "${var.prefix}-oidc"
  description    = "Trust OIDC M2M tokens"

  # OIDC provider details
  issuer    = var.oidc_issuer
  subject   = var.oidc_client
  audiences = [var.oidc_client]
}

# Azure Bot Service
resource "azurerm_bot_service_azure_bot" "teams_bot" {
  name                    = "${var.prefix}-teams-bot-${random_string.bot_suffix.result}"
  resource_group_name     = azurerm_resource_group.teams_bot.name
  location                = "global"
  microsoft_app_id        = azuread_application.teams_bot.client_id
  microsoft_app_type      = "SingleTenant"
  microsoft_app_tenant_id = data.azuread_client_config.current.tenant_id
  sku                     = "F0"
  tags                    = var.tags

  endpoint = var.bot_endpoint
}

# Enable Teams channel for the bot
resource "azurerm_bot_channel_ms_teams" "teams_channel" {
  bot_name            = azurerm_bot_service_azure_bot.teams_bot.name
  resource_group_name = azurerm_resource_group.teams_bot.name
  location            = azurerm_bot_service_azure_bot.teams_bot.location
}

# Grant admin consent for application permissions
# NOTE: Requires admin privileges
resource "azuread_app_role_assignment" "msgraph_permissions" {
  for_each = local.msgraph_permissions

  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids[each.key]
  principal_object_id = azuread_service_principal.teams_bot.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}
