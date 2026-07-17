# Root config for Kong Konnect units.
# Catalog units do `include "root" { path = find_in_parent_folders("root.hcl") }`,
# so this file supplies the backend + provider for everything generated beneath it.
#
# State backend: one shared Azure Storage Account, one container per group
# (see each group's env.hcl for tfstate_container — sand's is "ayasand"). All
# kong state lives under the kong-dcgw/ prefix within that container, followed
# by the real relative path (control_plane_groups/..., control_planes/...,
# apps/...) — terraform_state_base already supplies that, so nothing else is
# hardcoded here. Auth is Azure AD (use_azuread_auth), not a storage account
# key — whoever runs plan/apply needs Storage Blob Data Contributor (or
# better) on the account via their Azure CLI login / managed identity.

locals {
  env_config        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  tfstate_container = local.env_config.locals.tfstate_container
  terraform_state_base = trimprefix(
    replace(path_relative_to_include(), ".terragrunt-stack/", ""),
    ".terragrunt-stack/"
  )
}

remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    # subscription_id      = "38e352cb-70b6-4b60-87d2-557f4f7829f7"
    # resource_group_name  = "wusayainfrahub"
    # storage_account_name = "wusayainfrahubsa"
    subscription_id      = "552bdc54-0a39-4040-9d8f-4002e8f572aa"
    resource_group_name  = "aya-sand-wus-sa-01_rg"
    storage_account_name = "ayasandwussa01"
    container_name       = local.tfstate_container
    key                  = "kong-dcgw/${local.terraform_state_base}/terraform.tfstate"
    use_azuread_auth     = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "konnect" {
  # Auth via env var for local dev.
  personal_access_token = "${get_env("KONNECT_PAT", "")}"
}
EOF
}
