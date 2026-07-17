# Sand control plane group — member control planes.
# Two members, sand and devsand. Each control_plane stack invocation creates
# its control plane, looks the group up by name, and joins ITSELF to the group
# (see stacks/kong/control_plane). The group itself (network, vHub peering,
# dataplane) is a separate stack/state — control_plane_groups/sand/wus3 — which
# must be applied first.

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

stack "sand" {
  source = get_env("TG_KONG_SOURCE", "ssh") == "https" ? "git::https://github.com/Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/control_plane?ref=CSE-552-kong-dcgw" : "git@github.com:Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/control_plane?ref=CSE-552-kong-dcgw"
  path   = "sand"
  values = {
    env           = "sand"
    service       = "kong"
    platformowner = local.env.platformowner

    control_plane_name       = "sand-wus3-dcgw-v1"
    control_plane_group_name = "sand-wus3-dcgw-group"

    # The group's managed cache add-on is already enabled
    # (control_plane_groups/sand/wus3), so the global rate-limiting plugin's
    # own dedicated partial can actually connect to it.
    redis_enabled = true

    # TEMPORARY: matches the name of an existing partial (id
    # e6cbf7c5-08f5-43d5-a25c-ec0549c189f3) being imported in under this
    # control plane, rather than creating a new one under the "correct"
    # name. See stacks/kong/todo.md — rename back to
    # "sand-wus3-dcgw-v1-global-redis-cache" once settled.
    redis_partial_name = "hello-api-service-redis-cache"
  }
}

# stack "devsand" {
#   source = "git::https://github.com/Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/control_plane?ref=CSE-552-kong-dcgw"
#   path   = "devsand"
#   values = {
#     env           = "devsand"
#     service       = "kong"
#     platformowner = local.env.platformowner

#     control_plane_name       = "devsand-wus3-dcgw-v1"
#     control_plane_group_name = "sand-wus3-dcgw-group"
#   }
# }
