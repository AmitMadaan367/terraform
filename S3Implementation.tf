resource "aws_s3_bucket" "MyFirstBucket" {
  bucket = "my-terraform-first-bucket"

  tags = {
    Name        = "My terraform bucket"
    Environment = "My-Dev"
  }

  versioning{
  enabled=true
  }
}