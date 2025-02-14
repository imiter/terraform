##########################################
# 0. Provider
# 1. Module 사용 test
##########################################

#
# 0. Provider
#
provider "aws" {
  region = "ap-northeast-2"
}

#
# 1. Module 사용 test
#
# 1) module myvpc
module "myvpc" {
    source = "../modules/vpc"
    vpc_cidr = "192.168.10.0/24" # child 모듈의 값이 오버라이트됨
    subnet_cidr = "192.168.10.0/25" # 변경가능한 모듈의 값을 변경할때 사용
}

# 2) module myec2

module "myec2" {
    source = "../modules/ec2"
}
