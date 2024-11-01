terraform {
  required_version = ">=1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.0.0"
    }
  }

}

locals {
  name_rfc1123 = lower(substr(join("-", regexall("[a-zA-Z0-9-]*", var.name)), 0, 63))
  common_tags = {
    ManagedBy = "terraform"
  }
}
