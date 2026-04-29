resource "aws_s3_bucket" "my_iac_bucket" {
  bucket = "my-iac-bucket"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_iac_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_sqs_queue" "my_iac_queue" {
  name = "my-iac-queue"
}

resource "aws_sns_topic" "my_iac_topic" {
  name = "my-iac-topic"
}

output "bucket_name" {
  value = aws_s3_bucket.my_iac_bucket.id
}

output "queue_url" {
  value = aws_sqs_queue.my_iac_queue.id
}
