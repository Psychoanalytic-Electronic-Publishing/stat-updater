resource "aws_s3_bucket" "archive" {
  bucket = "${var.stack_name}-archive-${var.env}"

  tags = {
    stack = var.stack_name
    env   = var.env
  }
}

resource "aws_s3_bucket_acl" "private" {
  bucket = aws_s3_bucket.archive.id
  acl    = "private"
}
