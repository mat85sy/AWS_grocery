# S3 Bucket for Avatars
resource "aws_s3_bucket" "avatars" {
  bucket = var.s3_bucket_name

  tags = {
    Name    = "${var.project_name}-avatars-bucket"
    Project = var.project_name
  }
}

# S3 Bucket Public Access Block (Block ALL public access)
resource "aws_s3_bucket_public_access_block" "avatars" {
  bucket = aws_s3_bucket.avatars.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
