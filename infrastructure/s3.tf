resource "aws_s3_bucket" "avatars" {
  bucket = "grocerymate-avatarsss"

  tags = {
    Name        = "grocerymate-avatars"
    Environment = "Dev"
  }
}