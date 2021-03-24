variable "region" {
  type        = string
  default     = "us-east-1" # CF distributions require certificates in us-east-1, so this is the default
  description = "Region for certificates"
}

variable "environment" {
  description = "Operational Environment"
  type        = string
}

variable "dns_zone" {
  description = "Primary DNS Zone"
  type        = string
}

variable "dns_zone_id" {
  description = "Primary DNS Zone ID"
  type        = string
}
