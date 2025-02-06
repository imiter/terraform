# 데이터 소스 단순 실습
# *단순한 데이터 소스 정의/사용을 실습해 본다.
##########################################
# Provider 설정
##########################################
provider "aws" {
    region = "us-east-2"
}

##########################################
# Resource 설정
##########################################
# Resource: aws_instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "myweb" {
  # AMI: Ubuntu 24.04 LTS(us-east-2)

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "myweb"
  }
}



# EC2 생성