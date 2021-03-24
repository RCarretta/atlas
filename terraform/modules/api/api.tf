resource "aws_api_gateway_rest_api" "api" {
  name        = "atlas-api-${var.environment}"
  description = "Atlas v1 API for ${var.environment} environment"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = jsonencode(yamldecode(file("./api.yaml")))

  tags = {
    Environment = var.environment
  }
}

# --- API Domain/Settings
# Establish ownership / TLS settings for API gateway
# Use a regional rather than edge-optimied type so we can customize our CloudFront distribution that fronts the API
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = var.dns_zone
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Environment = var.environment
  }
}

# Map this API stage to the root of the domain
resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api.id
  domain_name = aws_api_gateway_domain_name.api.domain_name
  stage_name  = aws_api_gateway_stage.v1.stage_name
}
# ---

# --- API Stage/Settings
resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1" #  DO NOT CHANGE THIS. If the API is to be versioned, add a new stage.
  tags = {
    Environment = var.environment
  }
}

# TODO FIXME Cloudwatch role ARN and CW infra necessary to pipe logs out
#resource "aws_api_gateway_method_settings" "atlas" {
#  rest_api_id = aws_api_gateway_rest_api.atlas.id
#  stage_name  = aws_api_gateway_stage.v1.stage_name
#  method_path = "*/*"  # format: path/METHOD
#
#  settings {
#    metrics_enabled = true
#    logging_level = "ERROR"
#    data_trace_enabled = false  # yay, debugging
#    caching_enabled = false  # TODO: i think we should cache in CF and not here, but revisit -RC
#  }
#}
# ---

# --- Deployment
resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}
# ---
