environment = "dev"
vpc_cidr    = "10.0.0.0/16"
azs         = ["ap-northeast-2a", "ap-northeast-2c"]
private_subnet = {
  subnet1 = {
    cidr = "10.0.1.0/24"
    az   = "ap-northeast-2a"
  }
  subnet2 = {
    cidr = "10.0.2.0/24"
    az   = "ap-northeast-2c"
  }
}