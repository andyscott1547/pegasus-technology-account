# /modules/tf_state/variables.tf

variable "name" {
  description = "Name of the DynamoDB table and S3 bucket used to store TF state"
  type        = string
  default     = "tf-state-bucket"
}

variable "access_logging_target_bucket" {
  description = "Name of logging bukcet used for s3 access logging"
  type        = string
  default     = null
}