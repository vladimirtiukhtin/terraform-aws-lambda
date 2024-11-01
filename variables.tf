variable "name" {
  description = "Common name, a unique identifier"
  type        = string
}

variable "source_path" {
  description = ""
  type        = string
}

variable "handler" {
  description = ""
  type        = string
}

variable "timeout" {
  description = "Amount of seconds after which lambda gets forcibly killed"
  type        = number
  default     = 180
}

variable "vpc_id" {
  description = ""
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = ""
  type        = list(any)
  default     = []
}

variable "environment_variables" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "AWS KMS ARN"
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = "Any additional Security Group IDs to attach to the instance."
  type        = list(string)

  validation {
    condition     = length(var.additional_security_group_ids) <= 4
    error_message = "Only 5 security groups are allowed per network interface. One has been already taken by the module."
  }

  default = []
}

variable "extra_tags" {
  description = "Map of additional tags to add to module's resources"
  type        = map(string)
  default     = {}
}
