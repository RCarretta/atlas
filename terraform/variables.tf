variable "region" {
  description = "Primary AWS Region"
  type        = string
}

variable "environment" {
  description = "Operational Environment"
  type        = string
}

variable "aws_account" {
  description = "AWS Account ID"
  type = string
}

variable "dns_zone" {
  description = "Primary DNS Zone"
  type        = string
}

variable "parent_zone" {
  description = "Parent (top level) DNS Zone for use with delegations"
  type        = string
}

variable "application_name" {
  description = "Name of the application"
  type = string
}

variable "pipeline_branch" {
  description = "Map of monitored branches for pipeline"
  type = map
}

variable "repositories" {
  description = "Map of repos for pipeline"
  type = map
}
