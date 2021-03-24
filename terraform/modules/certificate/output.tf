output "certificate_arn" {
  value = aws_acm_certificate_validation.root_certificate_validation_workflow.certificate_arn
}
