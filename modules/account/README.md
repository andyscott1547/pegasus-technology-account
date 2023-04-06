# AWS Terraform Account Bootstrap module.

Basic module to bootstrap a new AWS Account ready for use.

- [Overview](#overview)
- [References](#references)
- [Terraform Docs](#terraform-docs)

## Overview

This Module helps to bootstrap a new AWS account. This will add some baseline configurations like enabling S3 Block Public Access and Default EBS encryption to help secure workloads.
All resources are optional but by default this module will enable:

* Create a S3 bucket for S3 access logging
* Create a S3 bucket and DynamoDB table for Terraform State
* Create a default AWS Support role
* Enable S3 Block Public Access
* Enable EBS Default Encryption
* Enable Security Hub 
* Enable Guardduty
* Enable Macie
* Enable Config
* Enable Inspector V1
* Enable Cloudtrail
* Set a recommended account level password policy

## References

* https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/welcome.html

## Terraform-Docs

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 4.0 |

#### Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |

#### Modules

| Name | Source | Version |
|------|--------|---------|
| cloudtrail | ./modules/cloudtrail | n/a |
| config | ./modules/config | n/a |
| s3_access_logging | ./modules/s3_access_logging | n/a |
| tf_state | ./modules/tf_state | n/a |

#### Resources

| Name | Type |
|------|------|
| [aws_accessanalyzer_analyzer.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_ebs_encryption_by_default.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_guardduty_detector.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_iam_account_password_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_role.support](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.support](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_inspector_assessment_target.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector_assessment_target) | resource |
| [aws_inspector_assessment_template.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector_assessment_template) | resource |
| [aws_inspector_resource_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector_resource_group) | resource |
| [aws_macie2_account.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_account) | resource |
| [aws_s3_account_public_access_block.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [aws_securityhub_account.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_standards_control.disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_control) | resource |
| [aws_securityhub_standards_subscription.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_inspector_rules_packages.rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/inspector_rules_packages) | data source |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access_analyzer_enabled | Boolean to enable/disable AWS Access Analyzer | `bool` | `true` | no |
| allow_users_to_change_password | Boolean to enable/disable IAM users to change their own password | `bool` | `true` | no |
| block_public_access_enabled | Boolean to enable/disable S3 block public access | `bool` | `true` | no |
| cloudtrail_enabled | Boolean to enable/disable Cloudtrail | `bool` | `true` | no |
| config_enabled | Boolean to enable/disable Config, security hub also depends on config being enabled | `bool` | `true` | no |
| ebs_encryption_enabled | Boolean to enable/disable EBS encryption | `bool` | `true` | no |
| guardduty_enabled | Boolean to enable/disable GuardDuty | `bool` | `true` | no |
| hard_expiry | Boolean to enable/disable IAM password policy hard expiry | `bool` | `true` | no |
| inspector_v1_enabled | Boolean to enable/disable Inspector V1 | `bool` | `true` | no |
| macie_enabled | Boolean to enable/disable Macie | `bool` | `true` | no |
| max_password_age | Maximum password age in days | `number` | `90` | no |
| minimum_password_length | Minimum password length | `number` | `14` | no |
| name | Name of the DynamoDB table and S3 bucket used to store TF state | `string` | `"tf-state-bucket"` | no |
| password_reuse_prevention | Number of previous passwords to prevent reuse | `number` | `24` | no |
| require_lowercase_characters | Boolean to enable/disable lowercase characters in IAM password policy | `bool` | `true` | no |
| require_numbers | Boolean to enable/disable numbers in IAM password policy | `bool` | `true` | no |
| require_symbols | Boolean to enable/disable symbols in IAM password policy | `bool` | `true` | no |
| require_uppercase_characters | Boolean to enable/disable uppercase characters in IAM password policy | `bool` | `true` | no |
| s3_access_logs_enabled | Boolean to enable/disable S3 access logging | `bool` | `true` | no |
| security_hub_enabled | Boolean to enable/disable Security Hub at an account level | `bool` | `true` | no |
| security_hub_standards | List of security hub standards to enable | `list(string)` | <pre>[<br>  "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"<br>]</pre> | no |
| support_role_enabled | Boolean to enable/disable support role | `bool` | `true` | no |
| suppress_benchmarks | suppress security benchmarks in security hub | `map(string)` | `{}` | no |
| tf_state_enabled | Boolean to enable/disable TF state | `bool` | `true` | no |

#### Outputs

No outputs.
<!-- END_TF_DOCS -->

### S3 Access Logging Module

<!-- BEGIN_S3_ACCESS_LOGGING_DOCS -->
#### Requirements

No requirements.

#### Providers

| Name | Version |
|------|---------|
| aws | n/a |

#### Modules

No modules.

#### Resources

| Name | Type |
|------|------|
| [aws_kms_alias.access_logging_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.access_logging_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.access_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.access_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_policy.access_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.access_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.access_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.access_logging_put_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.access_logging_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

#### Inputs

No inputs.

#### Outputs

| Name | Description |
|------|-------------|
| bucket_name | Name of bucket created for s3 access logging |
<!-- END_S3_ACCESS_LOGGING_DOCS -->

### Terraform State Module

<!-- BEGIN_TF_STATE_DOCS -->
#### Requirements

No requirements.

#### Providers

| Name | Version |
|------|---------|
| aws | n/a |

#### Modules

No modules.

#### Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access_logging_target_bucket | Name of logging bukcet used for s3 access logging | `string` | `null` | no |
| name | Name of the DynamoDB table and S3 bucket used to store TF state | `string` | `"tf-state-bucket"` | no |

#### Outputs

| Name | Description |
|------|-------------|
| bucket_arn | ARN of bucket created for terraform state |
| bucket_name | Name of bucket created for terraform state |
| table_arn | ARN of dynamodb table created for terraform state |
| table_name | Name of dynamodb table created for terraform state |
<!-- END_TF_STATE_DOCS -->

### AWS Config Module

<!-- BEGIN_CONFIG_DOCS -->
#### Requirements

No requirements.

#### Providers

| Name | Version |
|------|---------|
| aws | n/a |

#### Modules

No modules.

#### Resources

| Name | Type |
|------|------|
| [aws_config_configuration_recorder.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_delivery_channel.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_iam_role.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.account_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.account_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_logging.account_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.account_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.account_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.account_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.account_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.https_account_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access_logging_target_bucket | Name of logging bukcet used for s3 access logging | `string` | `null` | no |

#### Outputs

No outputs.
<!-- END_CONFIG_DOCS -->

### Cloudtrail Module 

<!-- BEGIN_CLOUDTRAIL_DOCS -->
#### Requirements

No requirements.

#### Providers

| Name | Version |
|------|---------|
| aws | n/a |

#### Modules

No modules.

#### Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.global](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.cloudwatch_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_delivery_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_logging.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudtrail_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_delivery_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access_logging_target_bucket | Name of logging bukcet used for s3 access logging | `string` | `null` | no |

#### Outputs

No outputs.
<!-- END_CLOUDTRAIL_DOCS -->