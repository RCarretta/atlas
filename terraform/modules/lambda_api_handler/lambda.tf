resource "aws_lambda_function" "lambda" {
  function_name                  = "${var.environment}-${var.lambda_name}"
  description                    = var.lambda_desc
  role                           = aws_iam_role.lambda.arn
  handler                        = var.lambda_handler
  runtime                        = var.lambda_runtime
  filename                       = "${path.module}/null.zip"
  timeout                        = var.lambda_timeout
  memory_size                    = var.lambda_memory
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  layers = var.lambda_layers
  publish                        = false

  environment {
    variables = merge(var.lambda_env_vars, {Environment="${var.environment}"})
  }

  dead_letter_config {
    target_arn = var.lambda_dead_letter_arn
  }

  tags = {
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      filename
    ]
  }
}
