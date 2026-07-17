# Shared identity for member-control-plane stacks under control_planes/<group>.
# These stacks only need platformowner (for tagging) — subscription/tenant/
# region/network config lives with the group's shared infra, one level up in
# control_plane_groups/<group>/env.hcl and .../wus3.

locals {
  platformowner = "gary.volz@ayahealthcare.com"
}
