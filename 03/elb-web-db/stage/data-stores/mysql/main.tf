###########################
# 0. Terraform 설정
# 1. Provider
# 2. DB Instance 생성
###########################

# 0. terraform
terraform {
  backend "s3" {
    bucket         = "mybucket-1993-0209"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "myDYDB"
  }
}
# 1. Provider
provider "aws" {
    region = "us-east-2"
}

# 2. DB Instance 생성
# Resource: aws_db_instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance

# db 구성시 중요한 변수 -> db_name, username, password은 따로 변수 설정
resource "aws_db_instance" "myDB" {
  allocated_storage    = 10
  db_name              = "myDB"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.dbuser
  password             = var.dbpassword
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}