# /modules/config/main.tf

resource "aws_config_configuration_recorder_status" "account" {
  name       = aws_config_configuration_recorder.account.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.account]
}

resource "aws_iam_role_policy_attachment" "account" {
  role       = aws_iam_role.account.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_s3_bucket" "account_config" {
  bucket        = "config-recorder-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  #checkov:skip=CKV_AWS_144:This bucket does not require cross region replication.
  #checkov:skip=CKV_AWS_145:This bucket is encrypted with default aws kms key.
}

resource "aws_s3_bucket_acl" "account_config" {
  bucket = aws_s3_bucket.account_config.id
  acl    = "private"
}

resource "aws_s3_bucket_logging" "account_config" {
  count         = var.access_logging_target_bucket != null ? 1 : 0
  bucket        = aws_s3_bucket.account_config.id
  target_bucket = var.access_logging_target_bucket
  target_prefix = "${aws_s3_bucket.account_config.id}/"
}

resource "aws_s3_bucket_versioning" "account_config" {
  bucket = aws_s3_bucket.account_config.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "account_config" {
  bucket = aws_s3_bucket.account_config.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "account_config" {
  bucket                  = aws_s3_bucket.account_config.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "account_config" {
  bucket = aws_s3_bucket.account_config.id
  policy = data.aws_iam_policy_document.https_account_config.json
}

data "aws_iam_policy_document" "https_account_config" {
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
      "${aws_s3_bucket.account_config.arn}/*",
      "${aws_s3_bucket.account_config.arn}"
    ]

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_config_delivery_channel" "account" {
  name           = "account-config-${data.aws_caller_identity.current.account_id}"
  s3_bucket_name = aws_s3_bucket.account_config.bucket
}

resource "aws_config_configuration_recorder" "account" {
  name     = "account-config-${data.aws_caller_identity.current.account_id}"
  role_arn = aws_iam_role.account.arn
  recording_group {
    all_supported                 = "true"
    include_global_resource_types = "true"
  }
}

resource "aws_iam_role" "account" {
  name = "account-config-${data.aws_caller_identity.current.account_id}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "account" {
  name = "account-config-policy-${data.aws_caller_identity.current.account_id}"
  role = aws_iam_role.account.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.account_config.arn}",
        "${aws_s3_bucket.account_config.arn}/*"
      ]
    }
  ]
}
POLICY
}