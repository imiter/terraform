##################################
# 0. Provider
# 1. Basic Infra
# 1) default vpc
# 2) default subnet
# 2. ALB - TG(ASG, EC2x2)
# 1) ALB - TG
#   - SG 생성
#   - TG 생성
#   - ALB 생성
#   - ALB listener 생성
#   - ALB listener rule 생성
# 2) ASG
#   - SG 생성
#   - LT 생성
#   - ASG 생성
##################################

#
# 0. Provider
#
provider "aws" {
  region = "us-east-2"
}

#
# 1. Basic Infra
#
# 1) default vpc
# Data Source: aws_vpc
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
# * default
data "aws_vpc" "default" {
  default = true
}

# 2) default subnet
# Data Source: aws_subnets
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#
# 2. ALB - TG(ASG, EC2x2)
#

# 1) ALB - TG
#   1-1) SG 생성
# Resource: aws_security_group
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "myALG_SG" {
  name        = "myALG_SG"
  description = "Allow 80 inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myALG_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myALG_SG_80" {
  security_group_id = aws_security_group.myALG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "myALB_SG_all" {
  security_group_id = aws_security_group.myALG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#   1-2) TG 생성
# Resource: aws_lb_target_group
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "myALB_TG" {
  name     = "myALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

#   1-3) ALB 생성
# Resource: aws_lb
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "myALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myALG_SG.id]
  subnets            = data.aws_subnets.default.ids
  enable_deletion_protection = false
}

#   1-4) ALB listener 생성
# Resource: aws_lb_listener
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "myALB_Listener" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALB_TG.arn
  }
}

#   1-5) ALB listener rule 생성
# Resource: aws_lb_listener_rule
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener_rule" "myALB_Listener_rule" {
  listener_arn = aws_lb_listener.myALB_Listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALB_TG.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# 2) ASG
#   2-1) SG 생성
# Resource: aws_security_group
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "myASG_SG" {
  name        = "myASG_SG"
  description = "Allow 80 inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myASG_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myASG_SG_80" {
  security_group_id = aws_security_group.myASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "myASG_SG_all" {
  security_group_id = aws_security_group.myASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#   2-2) LT(Launch Template) 생성

# Data Source: aws_ami
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
# * Ubuntu 24.04 LTS(us-east-2)
data "aws_ami" "myami" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# The terraform_remote_state Data Source
# https://developer.hashicorp.com/terraform/language/backend/s3#data-source-configuration
data "terraform_remote_state" "myTerraformRemoteState" {
  backend = "s3"
  config = {
    bucket = "mybucket-1993-0209"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
  }
}

# Resource: aws_launch_template
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "myLT" {
  name = "myLT"
  image_id = data.aws_ami.myami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.myASG_SG.id]
  # user_data = filebase64("${path.module}/example.sh")
  user_data = base64encode(templatefile("user-data.sh", {
    db_address = data.terraform_remote_state.myTerraformRemoteState.outputs.address,
    db_port = data.terraform_remote_state.myTerraformRemoteState.outputs.port,
    server_port = 80
  }))
}

#   2-3) ASG 생성
# Resource: aws_autoscaling_group
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group

resource "aws_autoscaling_group" "myASG" {
  name                      = "myASG"
  max_size                  = 2
  min_size                  = 2
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_template {
    id      = aws_launch_template.myLT.id
    version = "$Latest"
  }
  vpc_zone_identifier       = data.aws_subnets.default.ids
  
  # 다음 내용은 반드시 점검해야 한다.
  target_group_arns = [aws_lb_target_group.myALB_TG.arn]

  tag {
    key                 = "name"
    value               = "myASG"
    propagate_at_launch = true
  }

}