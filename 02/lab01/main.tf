#작업 순서
# vpc 생성
# vpc에 public subnet
# internet gateway 생성
# Routing table 생성
# public subnet에 연결

# provider 생성
provider "aws" {
  region = "us-east-2"
}

# vpc 생성
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}