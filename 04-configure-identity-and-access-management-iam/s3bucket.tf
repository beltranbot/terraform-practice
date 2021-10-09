# create a s3 bucket
resource "aws_s3_bucket" "custom-s3-bucket-01" {
  acl    = "private"
  tags = {
    Name = "bucket_demo"
  }
}
