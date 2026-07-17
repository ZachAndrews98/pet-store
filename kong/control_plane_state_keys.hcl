# Single source of truth for each control plane's mtls_leaf_cert unit's
# exact Terraform state blob key (container + key) — needed because apps
# read the control plane's shared leaf cert via terraform_remote_state
# (control planes and apps are independently deployed stacks; no Terragrunt
# `dependency` block can reach across them, only a real remote-state read
# keyed by the exact backend config).
#
# There's no formal, derivable relationship between a control plane's
# Konnect name (e.g. "sand-wus3-dcgw-v1") and its live-repo directory/state-
# key structure — each entry below was confirmed by reading the real
# generated backend.tf for that control plane's mtls_leaf_cert unit, not
# guessed. Add an entry here whenever a new control plane's mtls_leaf_cert
# is applied for the first time.

locals {
  mtls_leaf_cert_state_keys = {
    "sand-wus3-dcgw-v1" = {
      container_name = "ayasand"
      key            = "kong-dcgw/control_planes/sand/sand/mtls_leaf_cert/terraform.tfstate"
    }
  }
}
