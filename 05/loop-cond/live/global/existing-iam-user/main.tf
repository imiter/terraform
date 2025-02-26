terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_user" "createuser" {
  # Make sure to update this to your own user name!
  for_each = toset(var.user_names)
  name = each.value
}

