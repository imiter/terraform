# Provider 설정
provider "aws" {
  region = "us-east-2"
}

# Resource 설정
# SG(8080/tcp) 생성
# EC2(user_data="WEB 서버 설정")


# 1) SG(8080/tcp) 생성
resource "aws_security_group" "mySG" {                   # security_group 생성
  name        = "allow_80"
  description = "Allow 80 inbound traffic and all outbound traffic"

  tags = {
    Name = "mySG" # 자원들을 나눌때도 사용한다.
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_all_all_http_ipv4" { # 아웃바운드 규칙 설정
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 2) EC2(user_data="WEB 서버 설정")

resource "aws_instance" "web_server" {
  ami           = "ami-0cb91c7de36eed2cb"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mySG.id]
  associate_public_ip_address = true # public ip 자동할당
  user_data_replace_on_change = true
  user_data = <<EOF
#!/bin/bash
sudo apt -y install apache2
echo "HELL" | sudo tee /var/www/html/index.html
sudo systemctl enable --now apache2
EOF

  tags = {
    Name = "web_server"
  }
}