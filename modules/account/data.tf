# data.terraform

data "aws_caller_identity" "current" {}

data "aws_inspector_rules_packages" "rules" {}