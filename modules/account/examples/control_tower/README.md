# Control Tower Example

## Usage 

```terraform
module "account_bootstrap" {
  source               = "andyscott1547/account-bootstrap/aws"
  version              = "1.1.2"
  security_hub_enabled = false
  guardduty_enabled    = false
  macie_enabled        = false
  config_enabled       = false
  inspector_v1_enabled = false
  cloudtrail_enabled   = false
}
```

## Terraform Docs

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 4.0 |

#### Providers

No providers.

#### Modules

| Name | Source | Version |
|------|--------|---------|
| account-bootstrap | andyscott1547/account-bootstrap/aws | 1.1.2 |

#### Resources

No resources.

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | value for the region | `string` | `"eu-west-1"` | no |
| tags | value for the tags | `map(string)` | `{}` | no |

#### Outputs

No outputs.
<!-- END_TF_DOCS -->