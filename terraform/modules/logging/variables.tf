variable "region" {
  type        = string
  default     = "us-east-1" # CF distributions require certificates in us-east-1, so this is the default
  description = "Region for certificates"
}

variable "environment" {
  description = "Operational Environment"
  type        = string
}

variable "application_name" {
  description = "Name of the application in question"
  type = string
}
