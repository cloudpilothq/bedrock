resource "aws_s3_bucket" "assets" {
  bucket        = "bedrock-assets-${var.student_id}"
  force_destroy = true
  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_s3_bucket_public_access_block" "assets_block" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

