/*output "s3_bucket_names" {
  description = "Display all s3 bucket names"
  value       = [for bucket in aws_s3_bucket.bucket1 : bucket.bucket]
}
output "s3_bucket_ids" {
  description = "Display all s3 bucket id's"
  value       = [for bucket in aws_s3_bucket.bucket1 : bucket.id]
}*/
output "formatted_project_name" {
  value = local.formatted_project_name
}
output "port_list" {
  value = local.port_list
}

output "sg_rulees" {
  value = local.sg_rules
}

output "instancez_size" {
  value = local.instance_size
}
output "credentials" {
  value = var.credentials
  sensitive = true
}
output "all_location" {
  value = local.all_locations
}
output "unique_locations" {
  value = local.unique_locations
}
output "positive_cost" {
  value = local.positive_cost
}
output "max_cost" {
  value = local.max_cost
}
output "min_cost" {
  value = local.min_cost
}
output "total_cost" {
  value = local.total_cost
}
output "avg_cost" {
  value = local.avg_cost
}
output "time" {
  value = local.current_timestamp
}
output "format1" {
  value = local.format1
}
output "format2" {
  value = local.format2
}
output "timestamp_name" {
  value = local.timestamp_name
}
output "config" {
  value = local.config_data
}
output "config_data" {
  description = "Configuration data from file"
  value       = { for k, v in local.config_data : k => v if k != "password"}
}
output "secret_arn" {
  description = "ARN of AWS Secrets Manager secret"
  value = aws_secretsmanager_secret.app_config.arn
}