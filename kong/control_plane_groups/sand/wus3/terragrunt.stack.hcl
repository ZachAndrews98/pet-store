# Sand control plane group — shared infrastructure (region wus3).
# The group control plane, one network, one Azure vHub peering, one private DNS
# set, and the one dataplane. Member control planes (sand, devsand) — each
# joining itself to this group — live in control_planes/sand.

locals {
  env  = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  cidr = read_terragrunt_config(find_in_parent_folders("cidr_allocations.hcl")).locals.cidr_allocations
}

stack "group" {
  source = get_env("TG_KONG_SOURCE", "ssh") == "https" ? "git::https://github.com/Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/control_plane_group?ref=CSE-552-kong-dcgw" : "git@github.com:Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/control_plane_group?ref=CSE-552-kong-dcgw"
  path   = "group"
  values = {
    env           = "sand"
    service       = "kong"
    platformowner = local.env.platformowner

    control_plane_name = "sand-wus3-dcgw-group"

    network_name = "azure-vhub-sand-wus3-api-network"
    cidr_block   = local.cidr.sand
    region       = local.env.region

    # This is a shared/central Azure vWAN hub in the connectivity subscription
    # (not sand's own subscription) — confirmed via
    # GET /v2/cloud-gateways/networks/{sand_network_id}/transit-gateways,
    # which returned this as the only attachment on sand's network. Naming
    # ("nonprod-...", "prod-wus3-vwan-rg") reflects how the shared hub itself
    # was provisioned, not which environment peers into it.
    vhub_peering_name        = "nonprod-wus3-vhub-1"
    vhub_resource_group_name = "prod-wus3-vwan-rg"
    vhub_subscription_id     = "2501ce5c-a05f-4720-8d00-10d1833378c6"
    vhub_tenant_id           = local.env.tenant_id
    vhub_name                = "nonprod-wus3-vhub-1"

    private_dns_vnet_link_name = "kong-sand-wus3-dns-link-v1"
    private_dns_links = {
      "private-sand-ayasandbox-com" = {
        domain_name            = "private.sand.ayasandbox.com"
        peer_tenant_id         = local.env.tenant_id
        peer_subscription_id   = local.env.subscription_id
        peer_resource_group_id = "aya-internal-dns-sand-wus-rg-1"
      }
      "sand-aya-internal" = {
        domain_name            = "sand.aya.internal"
        peer_tenant_id         = local.env.tenant_id
        peer_subscription_id   = local.env.subscription_id
        peer_resource_group_id = "aya-internal-dns-sand-wus-rg-1"
      }
    }

    gateway_version    = "3.14"
    autoscale_base_rps = 100
    # KONG_HEADERS=on is now the unit's default (units/kong/cloud_gateway_configuration)
    # — no need to set dataplane_environment here unless overriding it.

    # Managed Redis-compatible cache add-on. No explicit region setting exists
    # on the add-on itself — it inherits the region(s) of the data-plane
    # groups already deployed for this control plane (cloud_gateway_configuration
    # above, region = westus3), so enabling it here is what puts it in wus3.
    redis_enabled = true
    redis_tier    = "small"
  }
}
