# variables.tf

variable "name" {
  description = "Name of the DynamoDB table and S3 bucket used to store TF state"
  type        = string
  default     = "tf-state"
}

variable "access_analyzer_enabled" {
  description = "Boolean to enable/disable AWS Access Analyzer"
  type        = bool
  default     = true
}

variable "block_public_access_enabled" {
  description = "Boolean to enable/disable S3 block public access"
  type        = bool
  default     = true
}

variable "ebs_encryption_enabled" {
  description = "Boolean to enable/disable EBS encryption"
  type        = bool
  default     = true
}

variable "allow_users_to_change_password" {
  description = "Boolean to enable/disable IAM users to change their own password"
  type        = bool
  default     = true
}

variable "hard_expiry" {
  description = "Boolean to enable/disable IAM password policy hard expiry"
  type        = bool
  default     = true
}

variable "max_password_age" {
  description = "Maximum password age in days"
  type        = number
  default     = 90
}

variable "minimum_password_length" {
  description = "Minimum password length"
  type        = number
  default     = 14
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords to prevent reuse"
  type        = number
  default     = 24
}

variable "require_lowercase_characters" {
  description = "Boolean to enable/disable lowercase characters in IAM password policy"
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Boolean to enable/disable numbers in IAM password policy"
  type        = bool
  default     = true
}

variable "require_symbols" {
  description = "Boolean to enable/disable symbols in IAM password policy"
  type        = bool
  default     = true
}

variable "require_uppercase_characters" {
  description = "Boolean to enable/disable uppercase characters in IAM password policy"
  type        = bool
  default     = true
}

variable "s3_access_logs_enabled" {
  description = "Boolean to enable/disable S3 access logging"
  type        = bool
  default     = true
}

variable "tf_state_enabled" {
  description = "Boolean to enable/disable TF state"
  type        = bool
  default     = true
}

variable "suppress_benchmarks" {
  description = "suppress security benchmarks in security hub"
  type        = map(string)
  default     = {}
}

variable "security_hub_enabled" {
  description = "Boolean to enable/disable Security Hub at an account level"
  type        = bool
  default     = true
}

variable "support_role_enabled" {
  description = "Boolean to enable/disable support role"
  type        = bool
  default     = true
}

variable "security_hub_standards" {
  description = "List of security hub standards to enable"
  type        = list(string)
  default     = ["arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"]
}

variable "guardduty_enabled" {
  description = "Boolean to enable/disable GuardDuty"
  type        = bool
  default     = true
}

variable "macie_enabled" {
  description = "Boolean to enable/disable Macie"
  type        = bool
  default     = true
}

variable "config_enabled" {
  description = "Boolean to enable/disable Config, security hub also depends on config being enabled"
  type        = bool
  default     = true
}

variable "inspector_v1_enabled" {
  description = "Boolean to enable/disable Inspector V1"
  type        = bool
  default     = true
}

variable "cloudtrail_enabled" {
  description = "Boolean to enable/disable Cloudtrail"
  type        = bool
  default     = true
}