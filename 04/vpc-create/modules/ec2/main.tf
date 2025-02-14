# 1. EC2 인스턴스 생성
# ami: ubuntu 24.04 LTS(ap-northeast-2)
# data소스를 사용하면 알아서 결정?
data "aws_ami" "ubuntu2404" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "myinstance" {
  ami           = data.aws_ami.ubuntu2404.id
  instance_type = var.instance_type
  tags = var.instance_tag
}