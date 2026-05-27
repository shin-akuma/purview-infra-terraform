## Description

This PR adds the Purview infrastructure code and environment configuration needed to deploy the data-governance stack.

## Included

- Terraform deployment logic for Purview, networking, diagnostics, RBAC, and budget in [main.tf](main.tf).
- Provider and subscription configuration in [providers.tf](providers.tf), including hub-subscription DNS lookup support.
- Input variables and defaults in [variables.tf](variables.tf).
- Outputs in [outputs.tf](outputs.tf).
- Naming conventions wiring in [naming-convention.tf](naming-convention.tf).
- Terragrunt environment layout in [env/common.hcl](env/common.hcl), [env/prd/data-governance-env.hcl](env/prd/data-governance-env.hcl), and [env/prd/data-governance/terragrunt.hcl](env/prd/data-governance/terragrunt.hcl).
- Pipeline definitions in [pipelines/validate.yml](pipelines/validate.yml) and [pipelines/deploy.yml](pipelines/deploy.yml).

## Testing Evidence

- Terraform and HCL files pass editor diagnostics.
- Full init/validate depends on access to remote module sources.