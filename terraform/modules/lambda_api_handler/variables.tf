variable "environment" {
  description = "Operational Environment"
  type        = string
}

variable "application_name" {
  description = "Name of the application in question"
  type = string
}

variable "lambda_name" {
  description = "Name of the lambda function"
  type = string
}

variable "lambda_desc" {
  description = "A short description of the function"
  type = string
}

variable "lambda_runtime" {
  description = "Which runtime to use"
  type = string
}

variable "lambda_handler" {
  description = "Function name of the handler"
  default = "lambda_handler"
  type = string
}

variable "lambda_policies" {
  description = "List of policy ARNs"
  type    = list
  default = []
}

variable "lambda_timeout" {
  description = "Maximum time for the lambda execution before terminated"
  type = number
  default = 10
}

variable "lambda_memory" {
  description = "How much memory (and CPU - see lambda documentation) to allocate to the function in MB"
  type = number
  default = 128
}

variable "lambda_reserved_concurrent_executions" {
  description = "How much reserved concurrency to allocate. Affects billing. -1 is nothing reserved"
  type = number
  default = -1
}

variable "lambda_env_vars" {
  description = "Envrionment variables to pass to the lambda function"
  default = {}
  type = map
}

variable "lambda_dead_letter_arn" {
  description = "ARN of SNS queue for dead letter processing"
  type = string
}

variable "lambda_layers" {
  description = "List of ARNs of lambda layers"
  default = []
  type = list
}
