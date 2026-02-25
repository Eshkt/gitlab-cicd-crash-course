
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
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.app_gtw.id
    }
    route {
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
    availability_zone = "us-east-1b"
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
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "Allow SSH traffic from Globe Tower/Office public IP"
        cidr_blocks = ["112.198.36.8/32"]
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
    ingress {
        description = "Allow all tcp Traffic"
        from_port = 0
        to_port = 65535
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

#7 network interface
resource "aws_network_interface" "py_app_nw_int" {
    subnet_id = aws_subnet.py_app_sn.id
    private_ips = ["192.168.1.24"] #just IP no cidr block
    security_groups = [aws_security_group.py_app_sg.id] 
}

#8 creating an elastic IP and associate it with the network interface
resource "aws_eip" "py_app_eip" {
    network_interface = aws_network_interface.py_app_nw_int.id
    domain = "vpc"
    depends_on = [ aws_internet_gateway.app_gtw, aws_instance.py_app_ec2]
}

#9 create a Instance
resource "aws_instance" "py_app_ec2" {
    ami = "ami-0c1fe732b5494dc14"
    instance_type = "t3.micro"
    availability_zone = "us-east-1b"
    key_name = "python-app-key"
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

    network_interface {
      network_interface_id = aws_network_interface.py_app_nw_int.id
      device_index = 0
    }

    user_data = <<-EOF
                sudo dnf update -y
                sudo dnf install -y docker
                sudo systemctl start docker
                sudo systemctl enable docker

                sudo usermod -a -G docker ec2-user

                sudo dnf install -y python3-certbot-nginx
                sudo systemctl start nginx
                sudo systemctl enable nginx


                EOF

    tags = {
        Name = "python-app-instance"
    }
}

    #Creating a IAM Role for EC2 Monitoring
resource "aws_iam_role" "ec2_role"{
    name = "ec2-monintoring-role"

    assume_role_policy = jsonencode({
        Version: "2012-10-17"
        Statement: [ 
            {
                Effect: "Allow"
                Action: "sts:AssumeRole"
                Principal: {
                    Service: "ec2.amazonaws.com"
                    }
                }
            ]
        })
    }

#Attaching a policy to the EC2 monitoring role
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

#creating a instance profile and attach the role to it in instance resource block
resource "aws_iam_instance_profile" "ec2_instance_profile"{
    name = "ec2-instance-profile"
    role = aws_iam_role.ec2_role.name
}

#     #Creating an IAM Roles for an ECR access
# resource "aws_iam_role" "ecr_access_role" {
#     name = "ecr-access-role"
#     assume_role_policy = jsonencode({
#     })
# }

