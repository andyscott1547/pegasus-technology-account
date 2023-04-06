# /modules/tf_state/locals.tf

locals {
  name = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.name}"
}