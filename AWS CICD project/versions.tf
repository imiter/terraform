# versions.tf파일 정의
# 팀프로젝트를 할시에 terraform의 버전에 제약 조건을 달아서 통합할때 문제 없이 진행.


terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"  # 서울 리전
}