# Microsoft Teams Bot Terraform Module

This Terraform module creates the Azure infrastructure required for Stacklet's Teams integration, including an Azure AD application with appropriate Microsoft Graph permissions and an Azure Bot Service configured for Teams.

## Quick Start

1. **Get configuration from Stacklet**: Download the `settings.auto.tfvars.json` file from Stacklet with your specific configuration values.

2. **Deploy the module**:
   ```bash
   terraform init
   terraform apply
   ```

3. **Copy the output**: After successful deployment, copy the `access_blob` output value and paste it back into the Stacklet UI.

## Prerequisites

### Azure CLI Authentication
You must be authenticated with the Azure CLI with sufficient permissions:

```bash
az login
```

If using the module directly (not as a `module` a wider setup), adding a provider declaration is also required:

```terraform
provider "azurerm" {
  features {}
}
```

### Required Azure Permissions

**Azure AD (Microsoft Entra ID):**
- **Application Administrator** role (recommended)
- Or **Global Administrator** (if Application Administrator is not available)

**Azure RBAC:**
- **User Access Administrator** + **Contributor** roles on the target subscription
- Or **Owner** role (combines both above)


## What This Module Creates

- **Azure AD Application** with Microsoft Graph permissions for Teams operations
- **Federated Identity Credential** for seamless authentication with Stacklet's platform
- **Azure Bot Service** with Teams channel enabled
- **Resource Group** to contain all resources

## Microsoft Graph Permissions

The module automatically grants the following Microsoft Graph permissions required for Stacklet's Teams integration:

- `User.Read.All` - Read user profiles to map from emails to identities
- `TeamsAppInstallation.ReadWriteSelfForTeam.All` - Install/uninstall app for teams
- `TeamsAppInstallation.ReadWriteSelfForUser.All` - Install/uninstall app for users
- `Team.ReadBasic.All` - Read basic team information for mapping configuration
- `Channel.ReadBasic.All` - Read basic channel information for mapping configuration
- `AppCatalog.Read.All` - Discover uploaded Teams app identity

Admin consent is automatically granted during deployment (no manual step required).

## Security

- **Passwordless authentication**: Uses federated identity credentials with Stacklet's platform
- **No secrets stored**: No application secrets are created or stored in Azure
- **Minimal permissions**: Only the Microsoft Graph permissions required for Teams functionality
- **Automatic admin consent**: Permissions are granted programmatically during deployment

## Troubleshooting

### Permission Denied Errors
- Verify you have **Application Administrator** (or **Global Administrator**) role in Azure AD
- Confirm you have **User Access Administrator** + **Contributor** (or **Owner**) roles in Azure
- Check that you're authenticated with `az login`

### Resource Provider Registration Issues
If you encounter errors about `Microsoft.BotService` provider registration taking too long or failing, this may be an issue with the AzureRM Terraform provider which can be remedied with:
```bash
az provider register --namespace Microsoft.BotService
```
Wait for registration to complete, then retry `terraform apply`.


### Need Help?
Contact your **Stacklet Customer Success team** for assistance with:
- Configuration issues
- Deployment problems
- Integration setup
- Any other questions about your Stacklet Teams integration

## Clean Up

To remove all resources created by this module:

```bash
terraform destroy
```

This will delete the resource group and all contained resources, including the Azure AD application and service principal.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.47 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.53.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.msgraph_permissions](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.teams_bot](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.oidc_provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azuread_service_principal.teams_bot](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_bot_channel_ms_teams.teams_channel](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bot_channel_ms_teams) | resource |
| [azurerm_bot_service_azure_bot.teams_bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bot_service_azure_bot) | resource |
| [azurerm_resource_group.teams_bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_string.bot_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bot_endpoint"></a> [bot\_endpoint](#input\_bot\_endpoint) | Bot webhook endpoint URL | `string` | n/a | yes |
| <a name="input_oidc_client"></a> [oidc\_client](#input\_oidc\_client) | OIDC client ID | `string` | n/a | yes |
| <a name="input_oidc_issuer"></a> [oidc\_issuer](#input\_oidc\_issuer) | OIDC issuer URL | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resource names (keep short to allow room for customer prefixes) | `string` | n/a | yes |
| <a name="input_roundtrip_digest"></a> [roundtrip\_digest](#input\_roundtrip\_digest) | Token used by the Stacklet Platform to detect mismatch between customerConfig and accessConfig. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all Azure resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_blob"></a> [access\_blob](#output\_access\_blob) | Configuration for Stacklet platform - copy this value to Stacklet Teams configuration |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Teams bot application/client ID |
| <a name="output_roundtrip_digest"></a> [roundtrip\_digest](#output\_roundtrip\_digest) | Configuration validation token |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Your Azure AD tenant ID |
<!-- END_TF_DOCS -->
