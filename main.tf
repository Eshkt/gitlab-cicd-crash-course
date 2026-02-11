provider "aws" {
    region = "us-east-1"
    #secret keys were configure in aws configure using AWS CLI
}

#1.Create VPC
resource "aws_vpc" "app_vpc" {
    cidr_block = "172.16.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "python-app-vpc"
    }
}

#2.Create Internet Gateway
resource "aws_internet_gateway" "app_gtw" {
    vpc_id = aws_vpc.app_vpc.id  
}

#3. Custome route table
resource "aws_route_table" "app_rt_tbl" {
    vpc_id = aws_vpc.app_vpc.id
    route {
        cidr_block = "172.16.1.0/24"
        gateway_id = aws_internet_gateway.app_gtw.id
    }
    tags = {
        Name = "python-app-table-route"
    }
}