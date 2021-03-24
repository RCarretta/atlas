provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "eldritch-atlas-infra"
    key     = "terraform/prod.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

locals {
  # This should match bucket in the S3 backend above.
  infra-bucket = "eldritch-atlas-infra"
}

