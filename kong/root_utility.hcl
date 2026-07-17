# Root config for provider-free utility modules (e.g. default_tags).
# Same backend as root.hcl; no provider block generated since these modules
# have no resources and need no provider.

remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    # New per-repo state path — switch back to this once we cut over off the
    # existing kong2 state tree.
    # path = "${get_repo_root()}/.terraform-state/${path_relative_to_include()}/terraform.tfstate"
    path = "C:/Projects/repos/state/kong2/${path_relative_to_include()}/terraform.tfstate"
  }
}
