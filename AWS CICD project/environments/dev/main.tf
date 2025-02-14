provider "aws" {
  region = "ap-northeast-2"
}

module "network" {
  source = "../../modules/network"
  
  environment = var.environment
  vpc_cidr = var.vpc_cidr
  azs = var.azs
  private_subnet = var.private_subnet
}

# network module out 출력
output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "private_db_subnet_ids" {
  value = module.network.private_db_subnet_ids
}