/*output "s3_bucket_names" {
  description = "Display all s3 bucket names"
  value       = [for bucket in aws_s3_bucket.bucket1 : bucket.bucket]
}
output "s3_bucket_ids" {
  description = "Display all s3 bucket id's"
  value       = [for bucket in aws_s3_bucket.bucket1 : bucket.id]
}*/