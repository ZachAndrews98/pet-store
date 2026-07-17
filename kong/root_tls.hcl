# Root config for hashicorp/tls-only units (local cert/key generation, no
# remote API calls). Same real backend as root.hcl — the tls provider needs
# no configuration at all, so this just supplies an empty provider block
# instead of the konnect one.

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

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "tls" {}
EOF
}
