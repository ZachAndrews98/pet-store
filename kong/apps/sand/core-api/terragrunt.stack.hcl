# core-api — sand.
#
# stacks/kong/app: control plane resolved by NAME via _data/control_plane
# (konnect_gateway_control_plane data source, filter.name.eq). gateway_service
# is one per app — any route that doesn't specify its own
# `service` block is automatically pointed at that one service.

locals {
  dcgw_version = "v1"

  oas_spec_path    = "swagger.json"
  oas_spec_content = file("${get_terragrunt_dir()}/${local.oas_spec_path}")
  oas_spec         = yamldecode(local.oas_spec_content)

  api_name = "core-api"
  api_slug = lower(replace(local.api_name, "/[^a-zA-Z0-9]+/", "-"))
}

stack "core_api" {
  source = get_env("TG_KONG_SOURCE", "ssh") == "https" ? "git::https://github.com/Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/app?ref=CSE-552-kong-dcgw" : "git@github.com:Aya-DevOpsTeam/infrastructure-catalog.git//stacks/kong/app?ref=CSE-552-kong-dcgw"
  path   = "core_api"
  values = {
    control_plane_name       = "sand-wus3-dcgw-${local.dcgw_version}"
    control_plane_group_name = "sand-wus3-dcgw-group"

    upstreams = {
      "${local.api_name}-upstream" = {
        healthcheck_http_path = "/api/home/get"
      }
    }

    targets = {
      "${local.api_name}-target-1" = {
        upstream_key = "${local.api_name}-upstream"
        target       = "coreapi-sand-wus-app-1.azurewebsites.net:443"
      }
      "${local.api_name}-target-2" = {
        upstream_key = "${local.api_name}-upstream"
        target       = "coreapi-sand-wus-app-2.azurewebsites.net:443"
      }
    }

    service_name = "${local.api_name}-service"
    service_host = "${local.api_name}-upstream" # matches the upstream key above, not a plain hostname

    route_name    = "${local.api_name}-route"
    route_hosts   = ["core-api.sand.ayasandbox.com"]
    route_paths   = ["/api/home/get"]
    route_methods = ["GET", "HEAD"]
    # strip_path's default (true) would strip the matched path off every
    # request before proxying (e.g. "/api/home/get" -> "", no path left).
    # false forwards the full path as-is.
    route_strip_path = false

    # cloudflare_zone_name   = "sand.ayasandbox.com"
    # cloudflare_record_name = "core-api.sand.ayasandbox.com"

    # Per-hostname mTLS opt-in — see stacks/kong/todo.md's mTLS section.
    mtls_enabled = true

    # Dev Portal / API catalog entry — see stacks/kong/app's api/api_version/
    # api_implementation units. api_implementation needs no values here: it
    # defaults to binding to this stack's own gateway_service. name, version,
    # description, and slug all come from the spec's info block above (locals),
    # rather than being retyped here — description is left unset when the
    # spec doesn't define one.
    api_name           = local.api_name
    api_version_number = local.oas_spec.info.version
    api_description    = try(local.oas_spec.info.description, null)
    api_slug           = local.api_slug
    api_spec_content   = local.oas_spec_content
  }
}
