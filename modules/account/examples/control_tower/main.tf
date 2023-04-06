# examples/basic/main.tf

module "account-bootstrap" {
  source               = "andyscott1547/account-bootstrap/aws"
  version              = "1.1.2"
  security_hub_enabled = false
  guardduty_enabled    = false
  macie_enabled        = false
  config_enabled       = false
  inspector_v1_enabled = false
  cloudtrail_enabled   = false
}