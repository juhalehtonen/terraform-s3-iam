# This S3, IAM user & policy creation tool requires Terraform 0.12.
#
# You can use an AWS credentials file to specify your credentials.
# The default location is $HOME/.aws/credentials on Linux and OS X.
# This way the Terraform configuration can be left without any mention
# of AWS access keys & secrets.
#
# Alternatively, you can use environment variables for all configuration.
#
# Below is an example of how to pass all required values as env vars:
#
# $ export AWS_ACCESS_KEY_ID="anaccesskey"
# $ export AWS_SECRET_ACCESS_KEY="asecretkey"
# $ export TF_VAR_project_name=theprojectname

# Variables
variable "project_name" {
  type = string
}

# Configure AWS. Credentials are loaded from the shared credentials or
# from the environment variables.
provider "aws" {
  region = "eu-north-1"
}

# Create a public-read S3 bucket
resource "aws_s3_bucket" "b" {
  bucket = "em87-${var.project_name}"
  acl    = "public-read"
}

# Create an IAM User and attach a policy directly.
resource "aws_iam_user" "lb" {
  name = "${var.project_name}_website"
}

# Provides an IAM access key. This is a set of credentials that allow API
# requests to be made as an IAM user.
resource "aws_iam_access_key" "lb" {
  user = "${aws_iam_user.lb.name}"
}

# Create user policy and attach directly to user
resource "aws_iam_user_policy" "lb" {
  name = "grant_${var.project_name}_s3_bucket_access"
  user = "${aws_iam_user.lb.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1500494355000",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteObject",
                "s3:Put*",
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.project_name}",
                "arn:aws:s3:::${var.project_name}/*"
            ]
        }
    ]
}
EOF
}

# Output our important values
output "user" {
  value = "${aws_iam_access_key.lb.user}"
}
output "bucket" {
  value = "${aws_s3_bucket.b.bucket}"
}
output "id" {
  value = "${aws_iam_access_key.lb.id}"
}
output "secret" {
  value = "${aws_iam_access_key.lb.secret}"
}
