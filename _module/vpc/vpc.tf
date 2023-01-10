resource "aws_vpc" "huyn_vpc" {
  cidr_block           = var.cidr_id
  enable_dns_hostnames = true
  tags = {
    "Name" = "huyn_vpc"
  }
}
resource "aws_internet_gateway" "huyn_igw" {
  vpc_id = aws_vpc.huyn_vpc.id
  tags = {
    "Name" = "huyn_igw"
  }
}
## AWS subnet

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.huyn_vpc.id
  count             = length(var.public_subnet)
  cidr_block        = var.public_subnet[count.index]
  availability_zone = var.az_list[count.index % length(var.az_list)]
  tags = {
    "Name" = "Public_subnet ${count.index}"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.huyn_vpc.id
  count             = length(var.private_subnet)
  cidr_block        = var.private_subnet[count.index]
  availability_zone = var.az_list[count.index % length(var.az_list)]
  tags = {
    "Name" = "Private_subnet ${count.index}"
  }
}
## AWS route table and association for public subnet

resource "aws_route_table" "huyn_rtb_public" {
  vpc_id = aws_vpc.huyn_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.huyn_igw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.huyn_igw.id
  }
  tags = {
    "Name" = "huyn_rtb_public"
  }
}
resource "aws_route_table_association" "public_association" {
  for_each       = { for k, v in aws_subnet.public_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.huyn_rtb_public.id
}
## AWS route table and association for private subnet

resource "aws_eip" "nat" {
  vpc = true
}
resource "aws_nat_gateway" "huyn_NAT_gw" {
  depends_on    = [aws_internet_gateway.huyn_igw]
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = {
    "Name" = "huyn_NAT_gw"
  }
}
resource "aws_route_table" "huyn_rtb_private" {
  vpc_id = aws_vpc.huyn_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.huyn_NAT_gw.id
  }
  tags = {
    "Name" = "huyn_rtb_private"
  }
}
resource "aws_route_table_association" "private_association" {
  for_each       = { for k, v in aws_subnet.private_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.huyn_rtb_private.id
}

# Network access control list
# resource "aws_network_acl" "huyn_nacl" {
#   vpc_id = aws_vpc.huyn_vpc.id
#   subnet_ids = [ aws_subnet.public_subnet[0].id ]
#   egress {
#     protocol = "-1"
#     rule_no = 100
#     action = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port = 0
#     to_port = 0
#   }
#   ingress {
#     protocol = "-1"
#     rule_no = 200
#     action = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port = 0
#     to_port = 0
#   } 
#   tags = {
#     "Name" = "huyn_nacl"
#   }
# }
