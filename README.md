# Purview Infrastructure (Terraform)

This repository deploys a production-oriented Microsoft Purview landing zone on Azure using Terraform.

## What This Deploys

The configuration provisions and configures:

1. Resource group for Purview platform resources.
2. Microsoft Purview account with system-assigned managed identity.
3. Key Vault using RBAC authorization, private-only access, soft-delete, and purge protection.
4. Diagnostic Storage Account (GRS, TLS 1.2+, public access disabled).
5. Private DNS zones (or references to existing hub zones) and VNet links.
6. Private endpoints for:
	- Purview account endpoint
	- Purview portal endpoint
	- Key Vault
	- Storage Blob
	- Storage Queue
	- Storage DFS
7. Diagnostic settings from Purview to Log Analytics and Storage.
8. Monthly resource group budget with email notifications.
9. RBAC assignments for Purview managed identity on subscription/data dependencies.
10. Network Security Group with explicit allow-list and default deny rules.

## Repository Layout

- `providers.tf`: Terraform and provider version constraints.
- `main.tf`: locals, data sources, resource group, and NSG.
- `purview.tf`: Purview account.
- `key_vault.tf`: Key Vault configuration.
- `storage.tf`: Diagnostic storage account.
- `private_dns.tf`: private DNS zones and links.
- `private_endpoints.tf`: all private endpoints.
- `rbac.tf`: role assignments for the Purview managed identity.
- `diagnostics.tf`: monitor diagnostic settings.
- `cost_alerts.tf`: budget and threshold notifications.
- `variables.tf`: input variables and defaults.
- `outputs.tf`: deployment outputs.
- `terraform.tfvars`: environment values (update placeholders before use).
- `pipelines/validate.yml`: PR validation pipeline.
- `pipelines/deploy.yml`: guarded manual deployment pipeline.

## Prerequisites

1. Terraform >= 1.9.0.
2. Azure CLI authenticated to the target tenant/subscription.
3. Permissions to create resources and role assignments in the target subscription.
4. Existing dependencies:
	- VNet and private endpoint subnet
	- Log Analytics workspace
	- ADLS Gen2 storage account (scan target)
	- Databricks workspace (scan target)

## Inputs

The full schema is in `variables.tf`. Key inputs you must set:

- `subscription_id`
- `environment` (`dev`, `test`, or `prod`)
- `purview_account_name` (globally unique)
- `key_vault_name` (globally unique)
- `diagnostic_storage_account_name` (globally unique, 3-24 lowercase alphanumeric)
- `existing_vnet_resource_id`
- `private_endpoint_subnet_name`
- `log_analytics_workspace_resource_id`
- `adls_storage_account_resource_id`
- `databricks_workspace_resource_id`
- `alert_email_addresses`

Optional/conditional:

- `create_private_dns_zones` (default `true`)
- `existing_private_dns_zone_resource_group_name` (required when `create_private_dns_zones = false`)
- `monthly_budget_amount`
- `budget_start_date`
- `soft_delete_retention_days`
- `tags`

## Configure Values

Update `terraform.tfvars` and replace all placeholder values that start with `REPLACE_`.

## Local Deployment

### 1) Initialize

```bash
terraform init
```

If you want remote state, uncomment and complete the `backend "azurerm"` block in `providers.tf` before running `terraform init`.

### 2) Validate

```bash
terraform fmt -check -recursive
terraform validate
```

### 3) Plan

```bash
terraform plan -var-file=terraform.tfvars -out=tfplan
```

### 4) Apply

```bash
terraform apply tfplan
```

## Outputs

After apply, useful outputs include:

- `resource_group_name`
- `purview_account_name`
- `purview_resource_id`
- `purview_managed_identity_principal_id`
- `purview_catalog_endpoint`
- `purview_scan_endpoint`
- `key_vault_resource_id`
- `key_vault_uri`
- `diagnostic_storage_account_id`
- `private_endpoint_ids`
- `purview_managed_resource_group_id`

Show outputs with:

```bash
terraform output
```

## CI/CD Pipelines

### Validate Pipeline (`pipelines/validate.yml`)

- Trigger: Pull requests to `main`.
- Steps: `terraform init -backend=false`, `terraform fmt -check`, `terraform validate`, `terraform plan`.
- Uses Azure DevOps OIDC-based auth environment variables for the AzureRM provider.

### Deploy Pipeline (`pipelines/deploy.yml`)

- Trigger: Manual only.
- Guard: Requires `confirmDeploy` parameter set to `DEPLOY`.
- Stages: Guard -> Validate -> Plan -> Apply.
- Apply stage targets Azure DevOps environment `purview-prod` (manual approval can be configured there).

## Important Notes

1. `terraform.tfvars` currently contains production-leaning defaults. Review carefully before non-prod deployments.
2. Purview public network access is noted as post-deployment controlled in Purview settings.
3. NSG association to the private endpoint subnet is documented in `main.tf` comments and may be managed separately.
4. Budget notifications require non-empty `alert_email_addresses`.
5. Private DNS behavior depends on `create_private_dns_zones`:
	- `true`: zones are created in this deployment resource group.
	- `false`: zones are read from `existing_private_dns_zone_resource_group_name`.

## Post-Deployment Validation Checklist

1. Confirm Purview account and managed resource group were created.
2. Confirm all six private endpoints are approved/connected.
3. Confirm private DNS zone links and A records resolve from inside the VNet.
4. Confirm Key Vault has public network disabled.
5. Confirm Purview diagnostic logs are flowing to Log Analytics/Storage.
6. Confirm budget appears with 80% actual, 90% forecast, and 100% actual notifications.
7. Confirm RBAC assignments exist for the Purview managed identity at expected scopes.