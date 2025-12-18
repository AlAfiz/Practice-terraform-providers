output "production_instance_id" {
  value = aws_instance.production_instance.id
}

output "testing_instance_id" {
  value = aws_instance.testing_instance.id
}

output "development_instance_id" {
  value = aws_instance.development_instance.id
}

output "production_public_ip" {
  value = aws_instance.production_instance.public_ip
}

output "testing_public_ip" {
  value = aws_instance.testing_instance.public_ip
}

output "development_public_ip" {
  value = aws_instance.development_instance.public_ip
}