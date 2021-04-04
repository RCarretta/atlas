variable "environment" {
  description = "Operational Environment"
  type        = string
}

variable "application_name" {
  description = "Name of the application in question"
  type = string
}

variable "artifact_bucket" {
  description = "Name of the S3 bucket to store artifacts"
  type = string
}

variable "web_bucket" {
  description = "Name of the S3 bucket used to service web requests"
  type = string
}

variable "monitored_branch" {
  description = "Name of the branch to monitor and build"
  type = string
}

variable "repository" {
  description = "ID of the Git org/repo to monitor and build"
  type = string
}

variable "build_timeout" {
  description = "Timeout in minutes the build is allowed to execute before failing"
  default = 5  # AWS default is 60 minutes
  type = number
}

variable "queued_timeout" {
  description = "Timeout in minutes build is allowed to be queued before failing"
  default = 5  # AWS default is 8 hours
  type = number
}

variable "build_badge_enabled" {
  description = "Whether or not to enable fancy build badge"
  default = false
  type = bool
}
variable "build_compute_type" {
  description = "Size and type of compute unit to use for build"
  default = "BUILD_GENERAL1_SMALL"  # Default is 3GB mem // 2 vcpu // 64gb disk linux container
  # see https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
  type = string
}

variable "build_image" {
  description = "Image to use for building"
  default = "aws/codebuild/standard:5.0"  # Default is ubuntu 20.04 latest cached docker image
  # see https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
  type = string
}

variable "build_privileged" {
  description = "Run build in privileged mode. Only necessary when building docker containers."
  type = bool
  default = false
}

variable "frontend_buildspec_filename" {
  description = "Filename of buildspec yaml"
  type = string
}

variable "codestar_connection_arn" {
  description = "Name of the AWS CodeStar connection"
  type = string
}

variable "log_group" {
  description = "Name of the build CloudWatch log group"
  type = string
}