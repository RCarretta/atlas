data "archive_file" "empty" {
  type        = "zip"
  output_path = "${path.module}/null.zip"

  source_dir = "${path.module}/null_handler/${var.lambda_runtime}"
}
