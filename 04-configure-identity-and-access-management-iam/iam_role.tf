# Role to access the AWS s3 bucket
resource "aws_iam_role" "s3-bucket-role" {
  name = "s3-bucket-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

# Policy to attach the s3 bucket role
resource "aws_iam_role_policy" "custom-s3-bucket-role-policy" {
  name = "custom-s3-bucket-role-policy"
  role = aws_iam_role.s3-bucket-role.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          "${aws_s3_bucket.custom-s3-bucket-01.arn}",
          "${aws_s3_bucket.custom-s3-bucket-01.arn}/*"
        ]
      }
    ]
  })
}

# Instance identifier
resource "aws_iam_instance_profile" "s3-bucket-role-instance-profile" {
  name = "s3-bucket-role-instance-profile"
  role = aws_iam_role.s3-bucket-role.name
}
