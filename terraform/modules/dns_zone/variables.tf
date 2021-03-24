variable "environment" {
  description = "Operational Environment"
  type        = string
}

variable "dns_zone" {
  description = "Primary DNS Zone"
  type        = string
}

variable "parent_zone" {
  description = "Parent (top level) DNS Zone for use with delegations"
  type        = string
}
