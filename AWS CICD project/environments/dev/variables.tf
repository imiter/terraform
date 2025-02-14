# dev/variables.tf
variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "private_subnet" {
  type = map(object({
    cidr = string
    az   = string
  }))
  description = "Private subnet configuration"
}