output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "iam_role_arn" {
  value      = aws_iam_role.uc_access.arn
  depends_on = [time_sleep.iam_propagation]
}
