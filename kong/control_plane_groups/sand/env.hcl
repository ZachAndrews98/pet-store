# Shared identity for the "sand" control plane group.
# Holds control planes: sand, devsand — sharing one network and one vhub peering.
# Read by control_plane_groups/sand/terragrunt.stack.hcl via find_in_parent_folders("env.hcl").

locals {
  group           = "sand"
  platformowner   = "gary.volz@ayahealthcare.com"
  subscription_id = "552bdc54-0a39-4040-9d8f-4002e8f572aa"
  tenant_id       = "c32ce235-4d9a-4296-a647-a9edb2912ac9"
  region          = "westus3"

  # Backend state configuration (Azure Storage Account — see root.hcl)
  tfstate_container = "ayasand"
}
