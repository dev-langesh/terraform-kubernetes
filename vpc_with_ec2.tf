terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "pub-1a" {

    vpc_id = aws_vpc.my_vpc.id

    cidr_block = "10.0.1.0/24"

    availability_zone = "ap-south-1a"

    map_public_ip_on_launch = true

    tags = {
      Name = "pub-1a"
    }
  
}

resource "aws_internet_gateway" "my_igw" {
  
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }

  
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_route_table"
  }

}

resource "aws_route_table_association" "route_table_asso" {
  route_table_id = aws_route_table.my_route_table.id
  subnet_id = aws_subnet.pub-1a.id
}

resource "aws_network_interface" "my_eni" {
  subnet_id = aws_subnet.pub-1a.id

  private_ips = ["10.0.1.100"]

  tags = {
    Name = "my_eni"
  }
}

resource "aws_instance" "ubuntu" {
  ami = "ami-0f5ee92e2d63afc18"

  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.my_eni.id
    device_index = 0
  }

  

  tags = {
    Name = "ubuntu"
  }
}
