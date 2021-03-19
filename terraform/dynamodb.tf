resource "aws_dynamodb_table" "atlas" {
  name         = "atlas-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  #  read_capacity  = 20
  #  write_capacity = 20
  hash_key  = "PK" # partition key
  range_key = "SK" # sort key

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Environment = var.environment
  }
}
