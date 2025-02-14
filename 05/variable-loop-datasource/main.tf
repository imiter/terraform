provider "aws" {
    region = "${var.regions}"
}


resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr}"
    instance_tenancy = "default"
    tags = {
        Name = "Main"
        Location = "Seoul"
    }
}

data "aws_availability_zones" "azs" {}

resource "aws_subnet" "subnets" {
    count = "${length(data.aws_availability_zones.azs.names)}"
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${element(var.vsubnet_cidr, count.index)}"
    availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"

    tags = {
        Name = "Subnet-${count.index+1}"
    }
}