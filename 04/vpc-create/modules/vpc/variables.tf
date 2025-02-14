#--- myvpc ---
variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type = string
  description = "vpc cidr block"
}

variable "vpc_tag" {
    default = {
        Name = "myvpc"
  }
    type = map(string)
    description = "VPC tag"
  
}
#--- mysubnet ---

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "subnet_tag" {
  default = {
    Name = "mysubnet"
  }
  type = map(string)
  description = "subnet tag"
}