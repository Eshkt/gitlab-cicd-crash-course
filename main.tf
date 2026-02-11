provider "aws" {
    region = "us-east-1"
    #secret keys were configure in aws configure using AWS CLI
}

#1.Create VPC
resource "aws_vpc" "app_vpc" {
    cidr_block = "192.168.0.0/16"
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
        cidr_block = "192.168.0.0/16"
        gateway_id = aws_internet_gateway.app_gtw.id
    }
    route = {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.app_gtw.id
    }
    tags = {
        Name = "python-app-table-route"
    }
}

#4 create a subnet
resource "aws_subnet" "py_app_sn" {
    vpc_id = aws_vpc.app_vpc.id
    cidr_block = "192.168.1.0/24"
    availability_zone = us-east-1b
    tags = {
        Name = "python-app-subnet"
    }
}

#5 Connect subent with route table
resource "aws_route_table_association" "py_app_rt_assoc" {
    subnet_id = aws_subnet.py_app_sn.id
    route_table_id =  aws_route_table.app_rt_tbl.id
}

#6 Creating sec group to allow port traffic
resource "aws_security_group" "py_app_sg" {
    name = "python-app-sg"
    description = "This is to allo traffic for the python app"
    vpc_id = aws_vpc.app_vpc.id
    ingress {
        description = "To allow ssh traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "To allow HTTP traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "To allow HTTPS traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "web_access_sg"
    }
  
}