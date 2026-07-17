# root.hcl's per-generated-unit lookup (find_in_parent_folders("env.hcl"))
# needs tfstate_container for the state backend — apps don't read anything
# else from env.hcl, so this is the only value here.

locals {
  tfstate_container = "ayasand"
}
