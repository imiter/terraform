variable "environment" {
  description = "환경 구분 (dev, prod 등)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "서브넷 ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 키페어 이름"
  type        = string
}
