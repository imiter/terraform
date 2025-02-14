resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# public subnet (ALB)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# availability_zone : (Optional) AZ for the subnet.
# map_public_ip_on_launch :(Optional) public ip 주소가 지정될때 사용. default = false 

# cidrsubnet(var.vpc_cidr, 8, count.index)
# - AZ1 (count.index = 0): 10.0.0.0/24
# - AZ2 (count.index = 1): 10.0.1.0/24
# cidrsubnet(var.vpc_cidr, 8, count.index + 2)
# - AZ1 (count.index = 0): 10.0.2.0/24
# - AZ2 (count.index = 1): 10.0.3.0/24

# cidrsubnet(prefix, newbits, netnum)
# - prefix: 기본 CIDR 블록 (예: "10.0.0.0/16")
# - newbits: 추가할 서브넷 비트 수 (여기서는 8)
# - netnum: 서브넷 번호 (0부터 시작)
resource "aws_subnet" "public" {
  count = length(var.azs)
  vpc_id = aws_vpc.myvpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
        Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# 프라이빗 서브넷 (web/was)
resource "aws_subnet" "private_subnet" {
  count = length(var.azs)
  vpc_id = aws_vpc.myvpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# 프라이빗 서브넷 (db)
resource "aws_subnet" "private_db" {
  count = length(var.azs)
  vpc_id = aws_vpc.myvpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.environment}-private-db-subnet-${count.index + 1}"
  }
}

# 인터넷 게이트 웨이
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# 

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id
  
  tags = {
    Name = "${var.environment}-internet-GW"
  }
}

# Nat gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "nat" {
  count = length(var.azs)
  domain   = "vpc"
}

# aws_nat_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "IGW" {
  count = length(var.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.environment}-nat-${count.index + 1}"
  }
}

# 라우팅 테이블 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# Public_rt
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.environment}-public-RT"
  }
}

# private_rt
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.myvpc.id
  count = length(var.azs)

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.IGW[count.index].id
  }

  tags = {
    Name = "${var.environment}-public-RT-${count.index + 1}"
  }
}

# 서브넷 연결
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
# public route table ass
resource "aws_route_table_association" "public" {
  count = length(var.azs)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_RT.id
}

# private route table ass
resource "aws_route_table_association" "private" {
  count = length(var.azs)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_RT[count.index].id
}

resource "aws_route_table_association" "private_db" {
  count = length(var.azs)
  subnet_id = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_RT[count.index].id
}

