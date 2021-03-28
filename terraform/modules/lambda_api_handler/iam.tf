resource "aws_iam_role" "lambda" {
  name = "${var.environment}-${var.lambda_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "logging" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
      "Effect": "Allow",
      "Action": ["sns:Publish"],
      "Resource": "${var.lambda_dead_letter_arn}"
    },
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents","xray:PutTraceSegments","xray:PutTelemetryRecords"],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "logging" {
  policy_arn = aws_iam_policy.logging.arn
  role = aws_iam_role.lambda.name
}

resource "aws_iam_role_policy_attachment" "policies" {
  count = length(var.lambda_policies)
  policy_arn = var.lambda_policies[count.index]
  role = aws_iam_role.lambda.name
}
