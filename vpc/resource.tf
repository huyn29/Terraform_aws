resource "aws_vpc" "huyn_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = var.name_vpc
  }
}
resource "aws_internet_gateway" "huyn_igw" {
    vpc_id = aws_vpc.huyn_vpc.id
    tags = {
      "Name" = "Huyn-igw"
    }
}
resource "aws_subnet" "huyn_subnet" {
  vpc_id = aws_vpc.huyn_vpc.id
  count = length(var.subnet_list)
  cidr_block = var.subnet_list[count.index]
  availability_zone = var.az_list[count.index]
  tags = {
    "Name" = "subnet ${count.index}"
  }
}
resource "aws_route_table" "huyn_rtb" {
  vpc_id = aws_vpc.huyn_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.huyn_igw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.huyn_igw.id
  }
  tags = {
    "Name" = "Huyn_rtb"
  }
}
resource "aws_route_table_association" "huyn_rta" {
  subnet_id = aws_subnet.huyn_subnet[0].id
  route_table_id = aws_route_table.huyn_rtb.id
}
resource "aws_network_acl" "huyn_nacl" {
  vpc_id = aws_vpc.huyn_vpc.id
  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  ingress {
    protocol = "-1"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  } 
  tags = {
    "Name" = "Huyn_nacl"
  }
}
resource "aws_security_group" "huyn_sg" {
  name = "huyn sg"
  vpc_id = aws_vpc.huyn_vpc.id
  # input
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  # output
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "Huyn_sg"
  }
}