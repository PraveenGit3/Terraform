provider "aws" {
  region  = "us-east-1"
  profile = "default"
  default_tags {
    tags = {
      Organisation = "ec2lab"
      Environment  = "dev"
    }
  }
}

resource "aws_instance" "ec2first" {
    ami = var.ami_id
    count = var.number_of_instances
   #  subnet_id = "{var.subnet_id}"
    instance_type = var.instance_type
   #  key_name = "{var.ami_key_pair_name}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "ec2vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "ec2vpc"
  }
}


resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.ec2vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name  = "public_subnet_{count.index}"
    Stack = count.index
  }
}

# resource "aws_subnet" "private" {
#   count                   = length(var.private_subnet_cidr_blocks)
#   vpc_id                  = aws_vpc.ec2first.id
#   cidr_block              = var.private_subnet_cidr_blocks[count.index]
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = false

#   tags = {
#     Name  = "private_subnet_{count.index}"
#     Stack = count.index
#   }
# }

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2vpc.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_route_table" "public_custom_route_table" {
  vpc_id = aws_vpc.ec2vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env}-public-crt"
  }
}


resource "aws_security_group" "demosg" {
   name        = "demosg"
  description = "Allow HTTP and SSH traffic via Terraform"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table_association" "public_crt_public_subnet" {
  count = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_custom_route_table.id
}     




