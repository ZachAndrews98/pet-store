# Root config for units that are pure terraform_remote_state reads (no
# resources, no provider needed at all — terraform_remote_state is a
# Terraform-core builtin). Same real backend as root.hcl/root_tls.hcl/
# root_cloudflare.hcl, but with NO generate "provider" block — a unit using
# this can't include any of those three instead, since each of them
# generates a provider block (konnect/tls/cloudflare) that a provider-less
# module doesn't declare in required_providers, the same class of error the
# tls-only units hit before root_tls.hcl was added.

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
    subscription_id      = "552bdc54-0a39-4040-9d8f-4002e8f572aa"
    resource_group_name  = "aya-sand-wus-sa-01_rg"
    storage_account_name = "ayasandwussa01"
    container_name       = local.tfstate_container
    key                  = "kong-dcgw/${local.terraform_state_base}/terraform.tfstate"
    use_azuread_auth     = true
  }
}
