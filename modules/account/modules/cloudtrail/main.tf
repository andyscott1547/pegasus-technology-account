# /modules/cloudtrail/main.tf

resource "aws_cloudwatch_log_group" "cloudtrail_events" {
  name              = "account-cloudtrail-${data.aws_caller_identity.current.account_id}"
  retention_in_days = "365"
}

data "aws_iam_policy_document" "cloudwatch_delivery" {
  statement {
    sid     = "AllowCloudTrailLogging"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "cloudwatch_delivery" {
  name               = "account-cloudtrail-${data.aws_caller_identity.current.account_id}"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_delivery.json
}

data "aws_iam_policy_document" "cloudwatch_delivery_policy" {
  statement {
    sid     = "AWSCloudTrailCreateLogs"
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_events.name}:log-stream:*",
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch_delivery_policy" {
  name   = "account-cloudwatch-policy-${data.aws_caller_identity.current.account_id}"
  role   = aws_iam_role.cloudwatch_delivery.id
  policy = data.aws_iam_policy_document.cloudwatch_delivery_policy.json
}


data "aws_iam_policy_document" "cloudtrail_key" {
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudtrailToEncryptLogs"
    effect = "Allow"

    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }

    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
    }
  }

  statement {
    sid    = "AllowCloudTrailToDescribeKey"
    effect = "Allow"

    principals {
      identifiers = ["cloudtrail.amazonaws.com"]
      type        = "Service"
    }

    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions   = ["kms:Decrypt", "kms:ReEncryptFrom"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "kms:CallerAccount"
    }

    condition {
      test     = "StringLike"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
      variable = "kms:kms:EncryptionContext:aws:cloudtrail:arn"
    }
  }

  statement {
    sid    = "AllowAliasCreationDuringSetup"
    effect = "Allow"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions   = ["kms:CreateAlias"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      values   = ["ec2.${data.aws_region.current.name}.amazonaws.com"]
      variable = "kms:ViaService"
    }

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "kms:CallerAccount"
    }
  }

  statement {
    effect = "Allow"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions   = ["kms:Decrypt", "kms:ReEncryptFrom"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "kms:CallerAccount"
    }

    condition {
      test     = "StringLike"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
    }
  }
}

resource "aws_kms_key" "cloudtrail" {
  description             = "A KMS key to encrypt CloudTrail events."
  deletion_window_in_days = "30"
  enable_key_rotation     = "true"
  policy                  = data.aws_iam_policy_document.cloudtrail_key.json
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

resource "aws_cloudtrail" "global" {
  name = "cvs-mgmt-cloudtrail"

  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_events.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch_delivery.arn
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "cloudtrail-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  #checkov:skip=CKV_AWS_144:This bucket does not require cross region replication.
  #checkov:skip=CKV_AWS_145:This bucket is encrypted with default aws kms key.
}

resource "aws_s3_bucket_acl" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  acl    = "private"
}

resource "aws_s3_bucket_logging" "cloudtrail" {
  count         = var.access_logging_target_bucket != null ? 1 : 0
  bucket        = aws_s3_bucket.cloudtrail.id
  target_bucket = var.access_logging_target_bucket
  target_prefix = "${aws_s3_bucket.cloudtrail.id}/"
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}

data "aws_iam_policy_document" "cloudtrail_s3" {
  statement {
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail.arn}/*",
      "${aws_s3_bucket.cloudtrail.arn}"
    ]

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.cloudtrail.arn
    ]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com", "config.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}