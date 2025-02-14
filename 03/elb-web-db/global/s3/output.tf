output "s3_bucket_arn" {
    value = aws_s3_bucket.mybucket.arn
    description = "S3 Bucket ARN"
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.myDYDB.name
    description = "DynamoDB table name"
}