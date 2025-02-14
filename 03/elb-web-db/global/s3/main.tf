##################################
# Provider
# s3 bucket 생성
# DynamoDB Table 생성
##################################


# 0.Provider
provider "aws" {
  region = "us-east-2"
}
# 1.s3 bucket 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# force_destroy
#  => Resource: aws_s3_bucket_versioning
#  => Resource: aws_s3_bucket_acl
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning

#  => Resource: aws_s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket" "mybucket" {
  bucket = "mybucket-1993-0209"
  force_destroy = true

  tags = {
    Name        = "My bucket"
  }
}
# # Resource: aws_s3_bucket_versioning
# resource "aws_s3_bucket_acl" "mybucket_versioning" {
#   bucket = aws_s3_bucket.mybucket.id
#   acl    = "private"
# }

# resource "aws_s3_bucket_versioning" "mybucket_enabled" {
#   bucket = aws_s3_bucket.mybucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# Resource: aws_s3_bucket_server_side_encryption_configuration
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration

# resource "aws_kms_key" "myKMSkey" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "mybucket_encryption" {
#   bucket = aws_s3_bucket.mybucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.myKMSkey.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# 2.DynamoDB Table 생성
resource "aws_dynamodb_table" "myDYDB" {
  name           = "myDYDB"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "myDYDB"
  }
}