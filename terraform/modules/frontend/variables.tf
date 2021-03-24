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

variable "logging_bucket_domain" {
  description = "Domain for logging bucket"
  type = string
}

variable "certificate_arn" {
  description = "ARN of TLS certificate to use"
  type = string
}

variable "application_name" {
  description = "Name of the application in question"
  type = string
}

variable "api_domain_name" {
  description = "The regional domain name of the API Gateway"
  type = string
}
