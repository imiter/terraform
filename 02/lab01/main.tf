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
  enable_dns_hostnames = true # vpc 생성 당시 dns hostname 활성화 시켜주는것 코드화 

  tags = {
    Name = "my_vpc"
  }
}

# internet gateway & vpc 연결
resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_gw"
  }
}

# subnet 생성
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet"
  }
}

# 라우팅 테이블 생성 
resource "aws_route_table" "my_routetable" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.my_gw.id
  }
  tags = {
    Name = "my_routetable"
  }
}

# Resourece: aws_route_table_association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_routetable.id
}

##############################
# 추가 실습
# 웹서버 ec2
##############################
# 작업: 웹서버 EC2(user_data)
# 작업 절차
# SG 생성

# 1) SG생성
# 1-1) security_group 생성 22,80 포트 OPEN
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow ssh,http inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "allow_ssh_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 2) EC2(user_data)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# vpc_security_group_ids
# user_data_replace_on_change
# sebnet_id
resource "aws_instance" "web" {
  # AMI: Amazon Linux 2023 AMI  
  ami           = "ami-018875e7376831abe"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  user_data_replace_on_change = true
  user_data = <<EOF
#!/bin/bash
yum -y install httpd
echo 'myweb' > /var/www/html/index.html
systemctl enable --now httpd
EOF
  tags = {
    Name = "web"
  }
}