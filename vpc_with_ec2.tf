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


# security group

resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow inbound traffic on ports 8000, SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_security_group"
  }
}

resource "aws_instance" "ubuntu" {
  ami = "ami-0f5ee92e2d63afc18"

  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  subnet_id = aws_subnet.pub-1a.id


  # network_interface {
  #   network_interface_id = aws_network_interface.my_eni.id
  #   device_index = 0
  # }

  

  tags = {
    Name = "ubuntu"
  }
}


# Create EBS volume
resource "aws_ebs_volume" "my_ebs_volume" {
  availability_zone = "ap-south-1a"
  size              = 10 # Size in GB

  tags = {
    Name = "my_ebs_volume"
  }
}

# Attach EBS volume to EC2 instance
resource "aws_volume_attachment" "my_volume_attachment" {
  device_name = "/dev/xvdf" # Specify the device name to attach the volume to

  volume_id  = aws_ebs_volume.my_ebs_volume.id
  instance_id = aws_instance.ubuntu.id
}
