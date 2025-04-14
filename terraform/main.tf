provider "aws" {
  region = var.aws_region
}

locals {
  aws_key = var.key_pair
}

resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/24"
 tags = {
   Name = "Project3 VPC"
 }

}
resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}

resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}
resource "aws_security_group" "vpc-web" {
  name        = "vpc-web"
  description = "VPC web"
  vpc_id = aws_vpc.main.id
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all IP and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_internet_gateway" "internet_gateway" {
 vpc_id = aws_vpc.main.id
 tags = {
   Name = "Project3 Internet Gateway"
 }
}
resource "aws_eip" "Nat-Gateway-elastic" {
  depends_on = [
    aws_route_table_association.public_subnet_asso
  ]
}
resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [
    aws_eip.Nat-Gateway-elastic
  ]
  allocation_id = aws_eip.Nat-Gateway-elastic.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "Project3 Nat Gateway"
  }
}

resource "aws_route_table" "public_route" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.internet_gateway.id
 }
 tags = {
   Name = "Public Route Table"
 }
}
resource "aws_route_table" "private_route" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_nat_gateway.nat_gateway.id
 }
 tags = {
   Name = "Private Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.public_route.id
}
resource "aws_route_table_association" "private_subnet_asso" {
 count = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = aws_route_table.private_route.id
}

resource "aws_instance" "my_server" {
  ami           =  var.ami_id
  key_name      = "${local.aws_key}"
  instance_type = var.ec2_instance_type
  # user_data     = file("wp_install.sh")
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = var.instance_name
  }
  vpc_security_group_ids = [ aws_security_group.vpc-web.id ]
  associate_public_ip_address = true
}
