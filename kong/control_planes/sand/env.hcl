# Sand-specific — separate from the shared control_planes/env.hcl.
#
# root.hcl's per-generated-unit lookup (find_in_parent_folders("env.hcl"),
# called from deep inside .terragrunt-stack/) needs tfstate_container, and it
# resolves to the NEAREST env.hcl in the real ancestor chain — this file,
# sitting next to terragrunt.stack.hcl, is a valid ancestor of everything
# generated beneath it, even though it's a SIBLING (not a parent) of the
# stack file's own top-level locals.env lookup, which still correctly finds
# the shared control_planes/env.hcl one level up for platformowner.

locals {
  tfstate_container = "ayasand"
}
