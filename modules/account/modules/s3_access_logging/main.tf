# /modules/s3_access_logging/main.tf

resource "aws_kms_key" "access_logging_s3" {
  description             = "KMS key used to encrypt organization management account s3"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "kms-access-logging-s3",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
POLICY
}

resource "aws_kms_alias" "access_logging_s3" {
  name          = "alias/access-logging-s3"
  target_key_id = aws_kms_key.access_logging_s3.key_id
}

resource "aws_s3_bucket" "access_logging" {
  bucket = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-access-logs"
  #checkov:skip=CKV_AWS_144:This bucket does not require cross region replication.
  #checkov:skip=CKV_AWS_145:This bucket is encrypted with default aws kms key.
}

resource "aws_s3_bucket_public_access_block" "access_logging" {
  bucket = aws_s3_bucket.access_logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "access_logging" {
  bucket = aws_s3_bucket.access_logging.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logging" {
  bucket = aws_s3_bucket.access_logging.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.access_logging_s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "access_logging" {
  bucket = aws_s3_bucket.access_logging.id
  policy = data.aws_iam_policy_document.access_logging.json
}

data "aws_iam_policy_document" "access_logging" {
  source_policy_documents = [
    data.aws_iam_policy_document.access_logging_tls.json,
    data.aws_iam_policy_document.access_logging_put_object.json
  ]
}

data "aws_iam_policy_document" "access_logging_tls" {
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
      "${aws_s3_bucket.access_logging.arn}/*",
      "${aws_s3_bucket.access_logging.arn}"
    ]

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

data "aws_iam_policy_document" "access_logging_put_object" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.access_logging.arn}/*",
      "${aws_s3_bucket.access_logging.arn}"
    ]
  }
}