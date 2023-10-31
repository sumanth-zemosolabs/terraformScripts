resource "aws_vpc" "sumanth-vpc" {
  cidr_block           = "10.0.0.0/16"
  tags                 = merge(local.tags, { "Name" : "sumanth-pola-vpc" })
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnets" {
  vpc_id = aws_vpc.sumanth-vpc.id
  for_each = {
    for value in var.subnet : value.Name => value
  }
  cidr_block              = each.value.cidr_block
  tags                    = merge(local.tags, { "Name" : each.key })
  map_public_ip_on_launch = each.value.enable_public_ip
  availability_zone       = each.value.availability_zone
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.sumanth-vpc.id
  tags   = merge(local.tags, { "Name" : "sumanth-pola-vpc-ig" })
}

resource "aws_nat_gateway" "nat-gateway" {
  tags          = merge(local.tags, { "Name" : "sp-vpc-nat" })
  allocation_id = aws_eip.eip.id
  subnet_id     = local.public_subnets[0]
  depends_on = [
    aws_subnet.subnets
  ]
}

resource "aws_eip" "eip" {
  tags = merge(local.tags, { "Name" : "sp-eip" })
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.sumanth-vpc.id
  tags   = merge(local.tags, { "Name" : "sp-public-rt" })
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.sumanth-vpc.id
  tags   = merge(local.tags, { "Name" : "sp-private-rt" })
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }
}

resource "aws_route_table_association" "public-rt-association" {
  count          = length(local.public_subnets)
  subnet_id      = local.public_subnets[count.index]
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-rt-association" {
  count          = length(local.private_subnets)
  subnet_id      = local.private_subnets[count.index]
  route_table_id = aws_route_table.private-rt.id
}