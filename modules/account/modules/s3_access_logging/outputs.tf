# modules/s3_access_logging/outputs.tf

output "bucket_name" {
  value       = aws_s3_bucket.access_logging.bucket
  description = "Name of bucket created for s3 access logging"
}