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

### Required Azure Permissions

**Azure AD (Microsoft Entra ID):**
- **Application Administrator** role (recommended)
- Or **Global Administrator** (if Application Administrator is not available)

**Azure RBAC:**
- **User Access Administrator** + **Contributor** roles on the target subscription
- Or **Owner** role (combines both above)

**Resource Provider:**
- `Microsoft.BotService` must be registered in your subscription:
  ```bash
  az provider register --namespace Microsoft.BotService
  ```

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

## Outputs

After successful deployment, you'll see these outputs:

| Name             | Description                                     |
|------------------|-------------------------------------------------|
| tenant_id        | Your Azure AD tenant ID                         |
| client_id        | Teams bot application/client ID                 |
| roundtrip_digest | Configuration validation token                  |
| access_blob      | **Copy this value to provide back to Stacklet** |

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

### Resource Provider Registration
If you see errors about `Microsoft.BotService`:
```bash
az provider register --namespace Microsoft.BotService
```
Wait for registration to complete before retrying.

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