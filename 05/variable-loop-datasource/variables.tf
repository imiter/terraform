variable "regions" {
  default = "us-east-2"
}

variable "vpc_cidr" {
    default = "192.168.0.0/16"
}

variable "vsubnet_cidr" {
  type = list
  default = ["192.168.1.0/24","192.168.2.0/24","192.168.3.0/24"]
}


# variable "asz" {
#     type = list
#     default = ["us-east-2a","us-east-2b","us-east-2c"]
# }
