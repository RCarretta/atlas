# General environment
region      = "us-east-1"
environment = "prod"
aws_account = "650462489189"

# DNS
dns_zone    = "eldritch-atlas.com"
parent_zone = "eldritch-atlas.com"

application_name = "atlas"

pipeline_branch = {
  frontend = "main"
}

repositories = {
  frontend = "eldritch-atlas/web-app"
}
