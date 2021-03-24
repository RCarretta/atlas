variable "certificate_arn" {
  description = "AWS ARN of TLS certificate to use"
  type = string
}

variable "environment" {
  description = "Operational Environment"
  type        = string
}

variable "dns_zone" {
  description = "Primary DNS Zone"
  type        = string
}
