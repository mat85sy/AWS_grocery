output "ec2_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "Public IP of EC2 instance"
}

output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS endpoint"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.avatars.bucket
  description = "S3 bucket for avatars"
}
