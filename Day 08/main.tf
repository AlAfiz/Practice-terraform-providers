  resource aws_s3_bucket "bucket5" {
    count = 2
    bucket = var.bucket_name[count.index]
    tags = var.tags
  }
  resource "aws_s3_bucket" "bucket10" {
    for_each = var.bucket_name_set #2
  bucket = each.key

  tags = var.tags
  depends_on = [aws_s3_bucket.bucket5]
  }
  resource "aws_s3_bucket" "bucket1" {
    count  = 2
    bucket = var.bucket_tasks[count.index]
    tags   = var.tags
  }
  resource "aws_s3_bucket" "bucket2" {
    for_each   = var.bucket_tasks_2
    bucket     = each.value
    tags       = var.tags
    depends_on = [aws_s3_bucket.bucket1]
  }
