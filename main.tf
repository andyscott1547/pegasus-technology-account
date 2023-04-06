# main

module "account-bootstrap" {
  source                      = "./modules/account"
  block_public_access_enabled = false
  security_hub_enabled        = false
  guardduty_enabled           = false
  macie_enabled               = false
  config_enabled              = false
  inspector_v1_enabled        = false
  cloudtrail_enabled          = false
}