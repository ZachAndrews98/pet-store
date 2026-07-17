# Single source of truth for each control plane's public edge DNS hostname.
#
# Kong Konnect does NOT expose this via any documented API field or Terraform
# attribute — confirmed against the provider schema (cloud_gateway_configuration's
# dataplane_groups only has egress/private IPs, ids, state, timestamps) and Kong's
# own docs, which describe retrieving it manually: "From the Connect menu, save the
# Public Edge DNS URL." (https://developer.konghq.com/dedicated-cloud-gateways/reference/)
#
# So: after a dcgw is first applied, open its control plane in the Konnect UI ->
# Connect to gateway -> Public edge DNS, and add the entry here ONCE. Every app
# attaching to that control plane reads it from here — no per-app duplication.
#
# TODO: every value below is a PLACEHOLDER, not a real endpoint — replace with the
# real "Connect to gateway" hostname for each dcgw once it exists.

locals {
  gateway_endpoints = {
    "sand-wus3-dcgw-v1"    = "TODO-placeholder.gateways.konggateway.com"
    "devsand-wus3-dcgw-v1" = "TODO-placeholder.gateways.konggateway.com"
    "dev-wus3-dcgw-v1"     = "TODO-placeholder.gateways.konggateway.com"
    "int-wus3-dcgw-v1"     = "TODO-placeholder.gateways.konggateway.com"
    "hot-wus3-dcgw-v1"     = "TODO-placeholder.gateways.konggateway.com"
    "prod-wus3-dcgw-v1"    = "TODO-placeholder.gateways.konggateway.com"
    "demo-wus3-dcgw-v1"    = "TODO-placeholder.gateways.konggateway.com"
  }
}
