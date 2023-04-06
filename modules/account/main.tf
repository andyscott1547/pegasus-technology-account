# main.tf

module "tf_state" {
  count                        = var.tf_state_enabled ? 1 : 0
  source                       = "./modules/tf_state"
  name                         = var.name
  access_logging_target_bucket = var.s3_access_logs_enabled ? module.s3_access_logging[0].bucket_name : null
}

module "s3_access_logging" {
  count  = var.s3_access_logs_enabled ? 1 : 0
  source = "./modules/s3_access_logging"
}

module "config" {
  count                        = var.config_enabled || var.security_hub_enabled ? 1 : 0
  source                       = "./modules/config"
  access_logging_target_bucket = var.s3_access_logs_enabled ? module.s3_access_logging[0].bucket_name : null
}

module "cloudtrail" {
  count                        = var.cloudtrail_enabled ? 1 : 0
  source                       = "./modules/cloudtrail"
  access_logging_target_bucket = var.s3_access_logs_enabled ? module.s3_access_logging[0].bucket_name : null
}

resource "aws_accessanalyzer_analyzer" "default" {
  count         = var.access_analyzer_enabled ? 1 : 0
  analyzer_name = "analyzer"
  type          = "ACCOUNT"
}

resource "aws_s3_account_public_access_block" "default" {
  count                   = var.block_public_access_enabled ? 1 : 0
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ebs_encryption_by_default" "default" {
  enabled = var.ebs_encryption_enabled
}

resource "aws_iam_account_password_policy" "default" {
  allow_users_to_change_password = var.allow_users_to_change_password
  hard_expiry                    = var.hard_expiry
  max_password_age               = var.max_password_age
  minimum_password_length        = var.minimum_password_length
  password_reuse_prevention      = var.password_reuse_prevention
  require_lowercase_characters   = var.require_lowercase_characters
  require_numbers                = var.require_numbers
  require_symbols                = var.require_symbols
  require_uppercase_characters   = var.require_uppercase_characters
}

resource "aws_iam_role" "support" {
  count              = var.support_role_enabled ? 1 : 0
  name               = "support"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy[0].json
}

data "aws_iam_policy_document" "assume-role-policy" {
  count   = var.support_role_enabled ? 1 : 0
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "support" {
  count      = var.support_role_enabled ? 1 : 0
  role       = aws_iam_role.support[0].id
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}

resource "aws_securityhub_standards_control" "disabled" {
  for_each              = var.suppress_benchmarks
  standards_control_arn = each.key
  control_status        = "DISABLED"
  disabled_reason       = each.value
}

resource "aws_securityhub_account" "default" {
  count = var.security_hub_enabled ? 1 : 0
  depends_on = [
    module.config
  ]
}

resource "aws_securityhub_standards_subscription" "default" {
  for_each      = var.security_hub_enabled ? toset(var.security_hub_standards) : toset([])
  standards_arn = each.value
  depends_on = [
    aws_securityhub_account.default,
    module.config
  ]
}

resource "aws_guardduty_detector" "default" {
  enable = var.guardduty_enabled

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }
}

resource "aws_macie2_account" "default" {
  count                        = var.macie_enabled ? 1 : 0
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

resource "aws_inspector_resource_group" "group" {
  count = var.inspector_v1_enabled ? 1 : 0
  tags = {
    inspector_enabled = "true"
  }
}

resource "aws_inspector_assessment_target" "assessment" {
  count              = var.inspector_v1_enabled ? 1 : 0
  name               = "account-inspector_v1-${data.aws_caller_identity.current.account_id}"
  resource_group_arn = aws_inspector_resource_group.group[0].arn
}

resource "aws_inspector_assessment_template" "assessment" {
  count      = var.inspector_v1_enabled ? 1 : 0
  name       = "account-inspector_v1-${data.aws_caller_identity.current.account_id}"
  target_arn = aws_inspector_assessment_target.assessment[0].arn
  duration   = "180"

  rules_package_arns = data.aws_inspector_rules_packages.rules.arns
}