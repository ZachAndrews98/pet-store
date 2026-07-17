# Single source of truth for Kong Cloud Gateway network CIDR ranges.
#
# Add an entry here BEFORE creating a new control plane group — never hand-pick a
# CIDR inline in a control_plane_groups/<group>/terragrunt.stack.hcl file.
#
# One CIDR per GROUP now, not per control plane — a control plane group gets
# exactly one shared Cloud Gateway network, peered once to an Azure vWAN hub, and
# every control plane in the group deploys into that same network. Top-level keys
# are the groups, each holding the real, deployable control planes that share one
# Azure subscription:
#   sand:    sand, devsand
#   nonprod: dev, int, hot
#   prod:    prod, demo
#
# Ranges must not overlap with each other, with any peered corporate VNet/vHub
# range, or with the private DNS resolver ranges.

locals {
  cidr_allocations = {
    sand    = "10.122.0.0/22"
    nonprod = "172.16.12.0/21" # 172.16.12.0 - 172.16.19.255
    prod    = "172.16.28.0/21" # 172.16.28.0 - 172.16.35.255
  }
}
