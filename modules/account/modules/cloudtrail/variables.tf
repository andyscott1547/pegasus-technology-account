# /modules/cloudtrail/variables.tf

variable "access_logging_target_bucket" {
  description = "Name of logging bukcet used for s3 access logging"
  type        = string
  default     = null
}