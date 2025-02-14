variable "vpc_cidr" {
  description = "vpc cidr block"
  type = string
}

variable "environment" {
  description = "dev"
  type = string
}

variable "private_subnet" {
  description = "vpc_subnet_cidr"
  type = map(object({
    cidr = string
    az = string
  }))
}

variable "azs" {
  description = "가용영역 리스트"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}