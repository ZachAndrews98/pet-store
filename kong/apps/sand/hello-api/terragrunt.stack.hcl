# hello-api — sand.
#
# stacks/kong/app: control plane resolved by NAME via _data/control_plane
# (konnect_gateway_control_plane data source, filter.name.eq). gateway_service
# is one per app — any route that doesn't specify its own
# `service` block is automatically pointed at that one service.

locals {
  # The ONLY thing that changes to migrate this app to a new dcgw version.
  dcgw_version = "v1"
}

stack "hello_api" {
  source = get_env("TG_KONG_SOURCE", "ssh") == "https" ? "git::https://github.com/Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/app?ref=CSE-552-kong-dcgw" : "git@github.com:Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/app?ref=CSE-552-kong-dcgw"
  path   = "hello_api"
  values = {
    control_plane_name       = "sand-wus3-dcgw-${local.dcgw_version}"
    control_plane_group_name = "sand-wus3-dcgw-group"

    upstreams = {
      "hello-api-upstream" = {
        healthcheck_http_path = "/api/hello"
      }
    }

    targets = {
      "hello-api-upstream-1" = {
        upstream_key = "hello-api-upstream"
        target       = "app1-sand.private.sand.ayasandbox.com:443"
      }
    }

    service_name = "hello-api-service"
    service_host = "hello-api-upstream" # matches the upstream key above, not a plain hostname

    route_name       = "hello-api-route"
    route_hosts      = ["hello-api.sand.ayasandbox.com"]
    route_paths      = ["/api/hello"]
    route_methods    = ["GET"]
    route_strip_path = false

    # sand.ayasandbox.com is a subdomain, not its own zone — ayasandbox.com
    # is the actual root zone (confirmed against the real Cloudflare account,
    # not the placeholder guess this used to be).
    cloudflare_zone_name   = "sand.ayasandbox.com"
    cloudflare_record_name = "hello-api.sand.ayasandbox.com"

    # Per-hostname mTLS opt-in — see stacks/kong/todo.md's mTLS section.
    mtls_enabled = true

    redis_rate_limiting_enabled = true
  }
}
